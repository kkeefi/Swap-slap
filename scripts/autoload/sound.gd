extends Node

const SR := 22050.0
const POOL := 8

var _pool  : Array = []
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

func _process(delta: float) -> void:
	pass
