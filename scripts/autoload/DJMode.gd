extends Node

const SEQ_DJ : Array = [KEY_H, KEY_I, KEY_T, KEY_S]
const SEQ_DEBUG : Array = [KEY_D, KEY_E, KEY_B, KEY_U, KEY_G]
var _key_history : Array = []

var dj_on : bool  = false
var dj_time : float = 0.0
var dj_beat_t : float = 0.0 
const DJ_BPM : float = 128.0
var dj_beat_ph : float = 0.0 

var eq_levels : Array = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
var eq_targets : Array = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
var eq_peak : Array = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
var eq_peak_t : Array = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]

const ARPEGGIO : Array = [261.6, 329.6, 392.0, 523.3, 392.0, 329.6, 523.3, 261.6]
var _arp_step : int = 0
var _arp_t : float = 0.0
var _audio_pool : Array = []
const POOL_SIZE : int  = 6

var debug_on : bool  = false
var _fps_acc : float = 0.0
var _fps_cnt : int = 0
var _fps_val : float = 60.0
var _bot_state : String = ""

var beat_this_frame : bool = false

func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_audio_pool.append(p)

func _input(ev: InputEvent) -> void:
	if not (ev is InputEventKey and ev.pressed and not ev.echo): return
	_key_history.append(ev.keycode)
	if _key_history.size() > 8:
		_key_history.pop_front()
	_check_combos()

func _check_combos() -> void:
	if _ends_with(_key_history, SEQ_DJ):
		dj_on = not dj_on
		Globals.dj_mode = dj_on
		if not dj_on: _stop_audio()
		_key_history.clear()
		print("[DJMode] DJ = ", dj_on)

	if _ends_with(_key_history, SEQ_DEBUG):
		debug_on = not debug_on
		Globals.debug_mode = debug_on
		_key_history.clear()
		print("[DJMode] Debug = ", debug_on)
		
func _ends_with(history: Array, seq: Array) -> bool:
	if history.size() < seq.size(): return false
	var off : int = history.size() - seq.size()
	for i in seq.size():
		if history[off + i] != seq[i]: return false
	return true
	
func update(delta: float) -> void:
	beat_this_frame = false

	_fps_acc += delta; _fps_cnt += 1
	if _fps_acc >= 0.5:
		_fps_val = float(_fps_cnt) / _fps_acc
		_fps_acc = 0.0; _fps_cnt = 0

	if not dj_on: return

	dj_time += delta

	var beat_dur : float = 60.0 / DJ_BPM
	dj_beat_t -= delta
	if dj_beat_t <= 0:
		dj_beat_t = beat_dur
		beat_this_frame = true
		_on_beat()

	dj_beat_ph = 1.0 - clamp(dj_beat_t / beat_dur, 0.0, 1.0)

	_arp_t -= delta
	if _arp_t <= 0:
		_arp_t = beat_dur * 0.5   # восьмая
		_play_note(ARPEGGIO[_arp_step])
		_arp_step = (_arp_step + 1) % ARPEGGIO.size()

	_update_eq(delta)
	
func _on_beat() -> void:
	eq_targets[0] = randf_range(0.8, 1.0)
	eq_targets[1] = randf_range(0.7, 0.95)
	eq_targets[2] = randf_range(0.4, 0.7)
	eq_targets[3] = randf_range(0.3, 0.6)
	eq_targets[4] = randf_range(0.25, 0.55)
	eq_targets[5] = randf_range(0.3, 0.65)
	eq_targets[6] = randf_range(0.35, 0.70)
	eq_targets[7] = randf_range(0.4, 0.80)
	
func _update_eq(delta: float) -> void:
	for i in 8:
		eq_targets[i] = clamp(float(eq_targets[i]) + randf_range(-0.15, 0.1) * delta * 8, 0.0, 1.0)

		var lv  : float = float(eq_levels[i])
		var tgt : float = float(eq_targets[i])

		if tgt > lv:
			eq_levels[i] = lerp(lv, tgt, delta * 22.0)
		else:
			eq_levels[i] = lerp(lv, tgt, delta * 4.5)

		if float(eq_levels[i]) >= float(eq_peak[i]):
			eq_peak[i]   = eq_levels[i]
			eq_peak_t[i] = 1.0
		else:
			eq_peak_t[i] = max(0.0, float(eq_peak_t[i]) - delta)
			if float(eq_peak_t[i]) <= 0:
				eq_peak[i] = lerp(float(eq_peak[i]), 0.0, delta * 3.0)
				
func _play_note(freq: float) -> void:
	var player : AudioStreamPlayer = null
	for p in _audio_pool:
		if not p.playing: player = p; break
	if player == null: player = _audio_pool[0]

	var dur : float = 0.18
	var sr : float = 22050.0
	var stream : AudioStreamGenerator = AudioStreamGenerator.new()
	stream.mix_rate = sr
	stream.buffer_length = dur + 0.05
	player.stream = stream
	player.volume_db = linear_to_db(0.16)
	player.play()

	var pb : AudioStreamGeneratorPlayback = player.get_stream_playback()
	if pb == null: return

	var frames : int = int(sr * dur)
	var buf : PackedVector2Array = PackedVector2Array()
	buf.resize(frames)

	for i in frames:
		var t : float = float(i) / sr
		var frac : float = float(i) / frames
		var env : float = exp(-frac * 7.0) * (1.0 - frac * 0.3)
		var s : float = sin(TAU * freq * t) * 0.55
		s += sin(TAU * freq * 2.0 * t) * 0.28
		s += sin(TAU * freq * 0.5 * t) * 0.17
		var sample : float = clamp(s * env, -1.0, 1.0)
		buf[i] = Vector2(sample, sample)

	pb.push_buffer(buf)
		
func _stop_audio() -> void:
	for p in _audio_pool:
		if p.playing: p.stop()
	for i in 8: eq_levels[i] = 0.0; eq_peak[i] = 0.0
	
func draw_visualizer(canvas: Node2D) -> void:
	if not dj_on: return

	var VW : float = Globals.VW
	var VH : float = Globals.VH
	var n : int = 8
	var bar_w : float = 18.0
	var bar_gap : float = 3.0
	var total_w : float = float(n) * (bar_w + bar_gap) - bar_gap
	var ox : float = VW/2.0 - total_w/2.0
	var base_y : float = VH - 4.0
	var max_h : float = 48.0

	canvas.draw_rect(Rect2(ox-5, base_y-max_h-5, total_w+10, max_h+8),
					 Color(0,0,0,0.58))

	for i in n:
		var x : float = ox + float(i) * (bar_w + bar_gap)
		var lv : float = float(eq_levels[i])
		var pk : float = float(eq_peak[i])
		var h : float = lv * max_h
		var ph : float = pk * max_h

		canvas.draw_rect(Rect2(x, base_y-max_h, bar_w, max_h), Color(0.06,0.06,0.10))

		if h > 0.5:
			var col : Color
			if lv < 0.5:
				col = Color(0.05,0.85,0.35).lerp(Color(0.95,0.88,0.08), lv*2.0)
			else:
				col = Color(0.95,0.88,0.08).lerp(Color(1.0,0.12,0.12), (lv-0.5)*2.0)
			canvas.draw_rect(Rect2(x, base_y-h, bar_w, h), col)
			canvas.draw_rect(Rect2(x, base_y-h, bar_w*0.28, h), Color(1,1,1,0.10))

		if ph > 1.5:
			canvas.draw_rect(Rect2(x, base_y-ph-2, bar_w, 2), Color(1.0,0.45,0.1,0.92))

	var pulse_alpha : float = 0.72 + sin(dj_time * TAU * (DJ_BPM/60.0)) * 0.28
	canvas.draw_string(ThemeDB.fallback_font, Vector2(ox, base_y - max_h - 8),
					   "♪  DJ MODE  ♪", HORIZONTAL_ALIGNMENT_LEFT, -1, 8,
					   Color(1.0, 0.58, 0.15, pulse_alpha))
					
func draw_debug(canvas: Node2D, players: Array, _platforms: Array) -> void:
	if not debug_on: return
	var font : Font = ThemeDB.fallback_font

	for p in players:
		if p.dead: continue
		var hb_col : Color = Color(1,0,0,0.30) if p.id==2 else Color(0,0.4,1,0.30)
		var hb_out : Color = Color(1,0,0,0.70) if p.id==2 else Color(0,0.4,1,0.70)
		var hbr : Rect2 = Rect2(
			p.pos.x - Globals.PW, p.pos.y - Globals.PH,
			Globals.PW * 2, Globals.PH * 2)
		canvas.draw_rect(hbr, hb_col)
		canvas.draw_rect(hbr, hb_out, false, 1.0)

		var vel_len : float = p.vel.length()
		if vel_len > 4:
			var vel_end : Vector2 = p.pos + p.vel * 0.06
			canvas.draw_line(p.pos, vel_end, Color(1,1,0,0.85), 1.5)

		canvas.draw_string(font, Vector2(p.pos.x - 24, p.pos.y - Globals.PH - 18),
						   "vx:%.0f vy:%.0f" % [p.vel.x, p.vel.y],
						   HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(1,1,1,0.85))
		canvas.draw_string(font, Vector2(p.pos.x - 24, p.pos.y - Globals.PH - 10),
						   "inv:%.2f cd:%.2f" % [float(p.inv_time), float(p.push_cd)],
						   HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(0.8,0.9,0.5,0.85))

	canvas.draw_rect(Rect2(2, 26, 85, 24), Color(0,0,0,0.72))
	canvas.draw_string(font, Vector2(5, 38), "FPS: %.0f" % _fps_val,
					   HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.2,1.0,0.2))
	canvas.draw_string(font, Vector2(5, 48),
					   "BOT: %s  DEBUG ON" % Globals.DIFF_NAMES[Globals.bot_difficulty],
					   HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1,0.8,0.2))
