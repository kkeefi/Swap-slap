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
var _audio_pool : Array = []
const POOL_SIZE : int = 6

var debug_on : bool  = false
var _fps_acc : float = 0.0
var _fps_cnt : int = 0
var _fps_val : float = 60.0

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
		
func _stop_audio() -> void:
	for p in _audio_pool:
		if p.playing: p.stop()
	for i in 8: eq_levels[i] = 0.0; eq_peak[i] = 0.0
