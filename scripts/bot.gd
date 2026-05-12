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
				
func _update_medium(delta: float, bot: Dictionary, enemy: Dictionary,
		platforms: Array, mode: int, king_rect: Rect2,
		lava_y: float, swap_ready_bot: bool) -> void:

	var bp : Vector2 = bot.pos
	var ep : Vector2 = enemy.pos

	if swap_ready_bot and (ep.x < 80 or ep.x > Globals.VW - 80):
		swap = true

	if mode == Globals.Mode.LAVA: _lava_survive(bot, platforms, lava_y); return
	if mode == Globals.Mode.KING: _king_logic(bot, enemy, king_rect); return

	var predicted_ep : Vector2 = ep + enemy.vel * 0.25
	predicted_ep.x = clamp(predicted_ep.x, 0, Globals.VW)
	predicted_ep.y = clamp(predicted_ep.y, 0, Globals.VH)
	var dist_pred : float = bp.distance_to(predicted_ep)

	_path_cd -= delta
	if _path_cd <= 0 or _astar_path.is_empty():
		_path_cd = PATH_RETHINK
		_astar_path = _astar_find_path(bp, predicted_ep, platforms)

	if not _astar_path.is_empty():
		var nxt : Vector2 = _astar_path[0]
		if bp.distance_to(nxt) < 20:
			_astar_path.pop_front()
		else:
			var dx : float = nxt.x - bp.x
			if abs(dx) > 8:
				if dx > 0: right = true
				else: left = true
			if (nxt.y < bp.y - 18) and bot.on_floor and _jump_cd <= 0:
				jump = true; _jump_cd = 0.45

	if _astar_path.is_empty():
		var dx : float = ep.x - bp.x
		if abs(dx) > 15:
			if dx > 0: right = true
			else: left = true

	if bot.on_floor and ep.y < bp.y - 25 and _jump_cd <= 0:
		jump = true
		_jump_cd = 0.45

	if dist_pred < REACT_DIST:
		push = true

	if (bp.x < 60 or bp.x > Globals.VW - 60) and not bot.on_floor:
		if bp.x < Globals.VW/2: right = true
		else: left = true

	if _stuck_timer > 0.4 and bot.on_floor and _jump_cd <= 0:
		jump = true; _jump_cd = 0.5; _stuck_timer = 0.0

func _astar_find_path(start: Vector2, target: Vector2, platforms: Array) -> Array:
	var points: Array = []
	points.append({"pos": start, "type": "start"})

	for pl in platforms:
		if not pl.alive: continue
		var r: Rect2 = pl.rect
		var land_x: float = r.get_center().x
		var land_y: float = r.position.y - Globals.PH - 2
		points.append({"pos": Vector2(land_x, land_y), "type": "plat"})

	points.append({"pos": target, "type": "target"})

	var n: int = points.size()
	if n < 2: return []
	
	var edges: Dictionary = {}
	for i in n:
		edges[i] = []
		for j in n:
			if i == j: continue
			if _can_jump_between(points[i].pos, points[j].pos):
				edges[i].append(j)

	var g: Dictionary = {}
	var f: Dictionary = {}
	var came_from: Dictionary = {}
	var open_set: Array = [0]

	for i in n:
		g[i] = INF
		f[i] = INF

	g[0] = 0.0
	f[0] = start.distance_to(target)

	while not open_set.is_empty():
		var current: int = open_set[0]
		for idx in open_set:
			if float(f[idx]) < float(f[current]):
				current = idx

		if current == n - 1:
			var path: Array = []
			var c: int = current
			while came_from.has(c):
				path.push_front(points[c].pos)
				c = came_from[c]
			return path

		open_set.erase(current)

		for neighbor in edges[current]:
			var tentative_g: float = float(g[current]) + points[current].pos.distance_to(points[neighbor].pos)
			if tentative_g < float(g[neighbor]):
				came_from[neighbor] = current
				g[neighbor] = tentative_g
				f[neighbor] = tentative_g + points[neighbor].pos.distance_to(target)
				if neighbor not in open_set:
					open_set.append(neighbor)

	return []
	
func _can_jump_between(a: Vector2, b: Vector2) -> bool:
	var dx : float = abs(b.x - a.x)
	var dy := a.y - b.y
	if dx > JUMP_DIST_MAX + 20: return false
	if dy > JUMP_H_MAX + 10: return false
	if dy < -JUMP_H_MAX * 2: return false
	return true

func _update_hard(delta: float, bot: Dictionary, enemy: Dictionary,
		platforms: Array, mode: int, king_rect: Rect2,
		lava_y: float, swap_ready_bot: bool) -> void:

	_update_medium(delta, bot, enemy, platforms, mode, king_rect, lava_y, swap_ready_bot)

	var bp: Vector2 = bot.pos
	var ep: Vector2 = enemy.pos
	var dist: float = bp.distance_to(ep)
	var dx: float = ep.x - bp.x

	if dist < REACT_DIST + 20:
		push = true

	if bot.on_floor and abs(ep.y - bp.y) > 15 and _jump_cd <= 0:
		jump = true
		_jump_cd = 0.35

	if abs(dx) > 10:
		if dx > 0: right = true
		else: left = true

func _lava_survive(bot: Dictionary, platforms: Array, lava_y: float) -> void:
	var bp : Vector2 = bot.pos
	var best_x : float = Globals.VW / 2.0
	var best_y : float = Globals.VH
	for pl in platforms:
		if not pl.alive: continue
		var r : Rect2 = pl.rect
		if r.position.y < best_y and r.position.y < lava_y - 20:
			best_y = r.position.y
			best_x = r.get_center().x
	var dx : float = best_x - bp.x
	if abs(dx) > 10:
		if dx > 0: right = true
		else: left = true
	if bot.on_floor and _jump_cd <= 0:
		if lava_y - (bp.y + Globals.PH) < 50 or best_y < bp.y - 20:
			jump = true; _jump_cd = 0.5

func _king_logic(bot: Dictionary, enemy: Dictionary, king_rect: Rect2) -> void:
	var bp : Vector2 = bot.pos
	var ep : Vector2 = enemy.pos
	var zone_cx : float = king_rect.position.x + king_rect.size.x / 2.0
	var in_zone : bool = _in_rect(bp, king_rect)
	var en_in : bool = _in_rect(ep, king_rect)

	if in_zone:
		if en_in:
			var dx : float = ep.x - bp.x
			if dx > 0: right = true
			else: left = true
			push = true
	else:
		var dx : float = zone_cx - bp.x
		if abs(dx) > 10:
			if dx > 0: right = true
			else: left = true
		if bot.on_floor and ep.y < bp.y - 20 and _jump_cd <= 0:
			jump = true; _jump_cd = 0.5

	if not in_zone and en_in and bp.distance_to(ep) < REACT_DIST:
		push = true

func _in_rect(pos: Vector2, r: Rect2) -> bool:
	return pos.x >= r.position.x and pos.x <= r.position.x + r.size.x and \
		   pos.y >= r.position.y and pos.y <= r.position.y + r.size.y
		
func get_h() -> float:
	return (1.0 if right else 0.0) - (1.0 if left else 0.0)

func get_jump_down(_just: bool) -> bool:
	var j : bool = jump
	jump = false
	return j

func get_push_down() -> bool:
	var p : bool = push
	push = false
	return p

func get_swap_down() -> bool:
	var s : bool = swap
	swap = false
	return s
