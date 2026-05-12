extends Node

const SR := 22050.0
const POOL := 8

var _pool  : Array = []
var _music : bool  = false
var _beat  : float = 0.0
var _step  : int   = 0
var _bstep : int   = 0
var _pat   : Array = []
var _bpat  : Array = []
const BPM  := 138.0

func _ready():
	for i in POOL:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_pool.append(p)
		
func _free_player() -> AudioStreamPlayer:
	for p in _pool:
		if not p.playing:
			return p
	return _pool[0]

static func _frac(x: float) -> float:
	return x - floor(x)

func _tone(freq: float, dur: float, shape: String = "sine",
		   vol: float = 0.42, atk: float = 0.01,
		   freq2: float = -1.0, dist: float = 0.0):
	var p: AudioStreamPlayer = _free_player()
	var st := AudioStreamGenerator.new()
	st.mix_rate = SR
	st.buffer_length = dur + 0.06
	p.stream = st
	p.volume_db = linear_to_db(clamp(vol, 0.01, 1.0))
	p.play()
	var pb := p.get_stream_playback()
	if pb == null:
		return

	var frames: int = int(SR * dur)
	var buf := PackedVector2Array()
	buf.resize(frames)
	var f0: float = freq
	var f1: float = freq2 if freq2 > 0 else freq
	var att: int = int(atk * SR)
	var rel: int = frames - int(0.14 * frames)

	for i in frames:
		var t: float = float(i) / SR
		var frac: float = float(i) / frames
		var fc: float = lerp(f0, f1, frac)
		var env: float = 1.0
		if i < att:
			env = float(i) / att
		elif i > rel:
			env = float(frames - i) / float(frames - rel)

		var s: float = 0.0
		match shape:
			"sine":
				s = sin(TAU * fc * t)
			"square":
				s = 1.0 if sin(TAU * fc * t) > 0 else -1.0
			"saw":
				s = 2.0 * _frac(fc * t) - 1.0
			"tri":
				var pp: float = _frac(fc * t)
				s = 4.0 * pp - 1.0 if pp < 0.5 else 3.0 - 4.0 * pp
			"noise":
				s = randf() * 2.0 - 1.0

		if dist > 0:
			s = clamp(s * (1.0 + dist * 8.0), -1.0, 1.0) * (1.0 - dist * 0.45)

		var sample: float = clamp(s * env, -1.0, 1.0)
		buf[i] = Vector2(sample, sample)

	pb.push_buffer(buf)
	
func play_jump():
	_tone(175, 0.15, "sine", 0.28, 0.005, 360)

func play_super_jump():
	_tone(130, 0.07, "noise", 0.26, 0.002, 70, 0.4)
	await get_tree().create_timer(0.04).timeout
	_tone(210, 0.22, "sine", 0.32, 0.005, 540)

func play_land():
	_tone(72, 0.09, "noise", 0.17, 0.002, 36, 0.3)

func play_push():
	_tone(58, 0.14, "square", 0.38, 0.002, 28, 0.4)
	await get_tree().create_timer(0.02).timeout
	_tone(780, 0.08, "sine", 0.19, 0.001, 160)

func play_push_glove():
	_tone(46, 0.20, "square", 0.50, 0.002, 22, 0.5)
	await get_tree().create_timer(0.01).timeout
	_tone(1050, 0.12, "sine", 0.28, 0.001, 240)

func play_swap():
	_tone(185, 0.28, "sine", 0.33, 0.01, 720, 0.07)
	await get_tree().create_timer(0.05).timeout
	_tone(720, 0.20, "sine", 0.24, 0.01, 185)

func play_swap_ready():
	_tone(520, 0.055, "sine", 0.19, 0.005, 700)
	await get_tree().create_timer(0.065).timeout
	_tone(700, 0.09, "sine", 0.24, 0.005, 880)

func play_chaos():
	_tone(145, 0.06, "square", 0.28, 0.002, 540, 0.4)
	await get_tree().create_timer(0.055).timeout
	_tone(540, 0.10, "square", 0.21, 0.002, 145, 0.4)

func play_pickup_glove():
	for i in 3:
		await get_tree().create_timer(i * 0.065).timeout
		_tone(380 + i * 180, 0.08 + i * 0.03, "sine", 0.24, 0.005, 560 + i * 180)

func play_pickup_boots():
	for i in 3:
		await get_tree().create_timer(i * 0.055).timeout
		_tone(260 + i * 170, 0.07 + i * 0.03, "tri", 0.23, 0.005, 430 + i * 170)

func play_death():
	_tone(180, 0.10, "square", 0.34, 0.002, 70, 0.3)
	await get_tree().create_timer(0.09).timeout
	_tone(85, 0.22, "noise", 0.25, 0.005, 36, 0.5)

func play_round_win():
	for i in 3:
		await get_tree().create_timer(i * 0.12).timeout
		_tone(380 + i * 95, 0.12, "sine", 0.27, 0.01, 470 + i * 95)

func play_crumble():
	_tone(105, 0.13, "noise", 0.19, 0.005, 52, 0.4)

func play_menu_move():
	_tone(285, 0.05, "sine", 0.14, 0.002, 340)

func play_menu_confirm():
	_tone(380, 0.07, "sine", 0.19, 0.005, 480)
	await get_tree().create_timer(0.07).timeout
	_tone(570, 0.10, "sine", 0.19, 0.005, 660)
	
func start_music(mode: int):
	_music = true
	_beat = 0.0
	_step = 0
	_bstep = 0
	match mode:
		0: _pat = [220,0,262,0,196,0,220,0,262,0,220,0,294,0,262,0]
		1: _pat = [196,0,220,0,175,0,196,0,220,0,175,0,147,0,175,0]
		2: _pat = [110,0,131,0,147,0,110,0,98,0,110,0,131,0,98,0]
		3: _pat = [330,0,294,0,330,0,349,0,392,0,349,0,330,0,294,0]
		4: _pat = [440,0,392,0,466,0,415,0,440,0,392,0,523,0,440,0]
		_: _pat = [220,0,262,0,196,0,220,0,262,0,220,0,294,0,262,0]
	
	_bpat = []
	for n in _pat:
		_bpat.append(int(n / 2.0) if n > 0 else 0)

func stop_music():
	_music = false

func _process(delta: float):
	if not _music:
		return
	_beat += delta
	var dur: float = 60.0 / BPM / 2.0
	if _beat >= dur:
		_beat -= dur
		var n_val: int = _pat[_step % _pat.size()]
		_step += 1
		if n_val > 0:
			var n: float = float(n_val)
			_tone(n, dur * 0.62, "tri", 0.09, 0.005, n * 0.988)
		if _step % 2 == 0:
			var b_val: int = _bpat[_bstep % _bpat.size()]
			_bstep += 1
			if b_val > 0:
				var b: float = float(b_val)
				_tone(b, dur * 1.2, "saw", 0.07, 0.02, b * 0.99, 0.05)
