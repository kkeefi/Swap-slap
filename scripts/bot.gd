extends Node

var left : bool = false
var right : bool = false
var jump : bool = false
var push : bool = false
var swap : bool = false

const REACT_DIST : float = 65.0
const EDGE_DANGER : float = 55.0
const JUMP_H_MAX : float = 52.0
const JUMP_DIST_MAX : float = 140.0

enum State { CHASE, ATTACK, RETREAT, SURVIVE, JUMP_TO }
var _state : int   = State.CHASE
var _jump_cd : float = 0.0
var _stuck_timer : float = 0.0
var _last_pos : Vector2 = Vector2.ZERO
var _dodge_dir : int   = 1

var _easy_think_cd : float = 0.0
var _easy_random : bool  = false

var _astar_path : Array = []
var _path_cd : float = 0.0
const PATH_RETHINK: float = 0.35

func reset() -> void:
	left=false; right=false; jump=false; push=false; swap=false
	_state=State.CHASE; _jump_cd=0.0; _stuck_timer=0.0
	_easy_think_cd=0.0; _easy_random=false
	_astar_path=[]; _path_cd=0.0

func update(delta: float, bot: Dictionary, enemy: Dictionary,
		platforms: Array, mode: int, king_rect: Rect2,
		lava_y: float, swap_ready_bot: bool) -> void:

	if _jump_cd > 0: _jump_cd -= delta
	left=false; right=false; jump=false; push=false; swap=false
	if bot.dead or enemy.dead: return
	if bot.pos.distance_to(_last_pos) < 0.8:
		_stuck_timer += delta
	else:
		_stuck_timer = 0.0
	_last_pos = bot.pos

	match Globals.bot_difficulty:
		Globals.BotDifficulty.EASY:
			_update_easy(delta, bot, enemy, platforms, mode, king_rect, lava_y, swap_ready_bot)
		Globals.BotDifficulty.MEDIUM:
			_update_medium(delta, bot, enemy, platforms, mode, king_rect, lava_y, swap_ready_bot)
		Globals.BotDifficulty.HARD:
			_update_hard(delta, bot, enemy, platforms, mode, king_rect, lava_y, swap_ready_bot)

func _update_easy(delta: float, bot: Dictionary, enemy: Dictionary,
		_platforms: Array, mode: int, king_rect: Rect2,
		lava_y: float, swap_ready_bot: bool) -> void:

	var bp : Vector2 = bot.pos
	var ep : Vector2 = enemy.pos
	var dist : float  = bp.distance_to(ep)

	if swap_ready_bot and (ep.x < 70 or ep.x > Globals.VW - 70) and randf() < 0.3:
		swap = true

	if mode == Globals.Mode.LAVA: _lava_survive(bot, _platforms, lava_y); return
	if mode == Globals.Mode.KING: _king_logic(bot, enemy, king_rect); return

	_easy_think_cd -= delta
	if _easy_think_cd > 0:
		_exec_easy_state(bp, ep, dist, bot)
		return

	_easy_think_cd = randf_range(0.15, 0.35)

	if randf() < 0.25:
		if randf() < 0.5: right = true
		else: left = true
		if randf() < 0.2 and bot.on_floor: jump = true
		return

	var near_edge_self : bool = bp.x < EDGE_DANGER or bp.x > Globals.VW - EDGE_DANGER
	var near_edge_enemy : bool = ep.x < EDGE_DANGER or ep.x > Globals.VW - EDGE_DANGER

	if near_edge_self and not bot.on_floor:
		_state = State.RETREAT
		_dodge_dir = int(-sign(bp.x - Globals.VW/2.0))
		if _dodge_dir == 0: _dodge_dir = 1
	elif _stuck_timer > 0.5:
		_state = State.JUMP_TO; _stuck_timer = 0.0
	elif dist < REACT_DIST:
		_state = State.ATTACK
	else:
		_state = State.CHASE

	_exec_easy_state(bp, ep, dist, bot)
	
func _exec_easy_state(bp: Vector2, ep: Vector2, dist: float, bot: Dictionary) -> void:
	var dx : float = ep.x - bp.x
	match _state:
		State.CHASE:
			if abs(dx) > 6:
				if dx > 0: right = true
				else: left = true
			if bot.on_floor and ep.y < bp.y - 25 and _jump_cd <= 0:
				jump = true; _jump_cd = 0.5
		State.ATTACK:
			if abs(dx) > 8:
				if dx > 0: right = true
				else: left = true
			if dist < REACT_DIST: push = true
			if bot.on_floor and abs(ep.y-bp.y) > 20 and _jump_cd <= 0:
				jump = true; _jump_cd = 0.4
		State.RETREAT:
			if _dodge_dir > 0: right = true
			else: left = true
			if bot.on_floor and _jump_cd <= 0:
				jump = true; _jump_cd = 0.6
		State.SURVIVE:
			var sd : int = 1 if bp.x < Globals.VW/2 else -1
			if sd > 0: right = true
			else: left = true
		State.JUMP_TO:
			if dx > 0: right = true
			else: left = true
			if bot.on_floor and _jump_cd <= 0:
				jump = true; _jump_cd = 0.5
				
func _update_medium(_d, _b, _e, _p, _m, _k, _l, _s) -> void: pass
func _update_hard(_d, _b, _e, _p, _m, _k, _l, _s) -> void: pass
func _lava_survive(_b, _p, _l) -> void: pass
func _king_logic(_b, _e, _k) -> void: pass












# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
