extends Node2D

enum Scene { MAIN_MENU, MODE_SELECT, MAP_SELECT, GAME, ROUND_END, MATCH_END }
var scene: int = Scene.MAIN_MENU
var main_menu_cursor: int = 0
var mode_cursor: int = 0
var map_cursor: int = 11
var game_active: bool  = false

var paused : bool = false
var pause_cursor : int  = 0

var players: Array = []

var swap_charge: Array = [0.0, 0.0]
var swap_ready: Array = [false, false]
const SWAP_TIME: float = 15.0
var swap_flash_alpha: float = 0.0
var swap_flash_who: int   = 0

var chaos_timer: float = 0.0
var chaos_interval: float = 4.0

var platforms: Array = []
var map_bg: int   = 0

var gloves_pos: Vector2 = Vector2.ZERO
var gloves_alive: bool = false
var gloves_bob: float = 0.0
var gloves_timer: float = 0.0
const GLOVES_INT: float = 22.0

var boots_pos: Vector2 = Vector2.ZERO
var boots_alive: bool = false
var boots_bob: float = 0.0
var boots_timer: float = 0.0
const BOOTS_INT: float = 28.0

var lava_y: float = 999.0
var lava_wave: float = 0.0
var lava_speed: float = 4.0

var king_rect: Rect2 = Rect2(0,0,0,0)
var king_time: Array = [0.0, 0.0]
var king_move_dir: int   = 1
var king_moves: bool = false

var crumble_accum: float = 0.0
var crumble_interval: float = 1.8

var menu_bob: float = 0.0
var menu_blink: float = 0.0
var game_time: float = 0.0

var announce_text: String = ""
var announce_timer: float  = 0.0
var announce_color: Color  = Globals.C_GOLD

var particles : Array = []
var danger_flash : float = 0.0

var round_end_timer : float = 0.0
var match_celebrate : float = 0.0

const WIN_SCORE: int = 3

var boids : Array = []

var diff_cursor: int  = 1
var in_diff_select: bool = false

func _process(delta: float) -> void:
	menu_bob += delta
	menu_blink += delta
	Backgrounds.update(delta)
	Renderer.update(delta)
	DjMode.update(delta)
	
	if not paused:
		for i in range(particles.size()-1, -1, -1):
			var p : Dictionary = particles[i]
			p.life -= delta
			p.pos  += p.vel * delta
			p.vel.y += 200.0 * delta
			if p.life <= 0:
				particles.remove_at(i)
		if announce_timer > 0: announce_timer -= delta
		if swap_flash_alpha > 0: swap_flash_alpha = max(0.0, swap_flash_alpha - delta * 3.0)
		if danger_flash > 0: danger_flash = max(0.0, danger_flash - delta * 4.0)
		_update_boids(delta)

	match scene:
		Scene.GAME:
			if game_active and not paused:
				game_time += delta
				_update_game(delta)
		Scene.ROUND_END:
			if not paused:
				round_end_timer -= delta
				if round_end_timer <= 0.0: _start_game()
		Scene.MATCH_END:
			match_celebrate += delta
			if fmod(match_celebrate,0.055) < 0.02: 
				_spawn_confetti()
	queue_redraw()

func _ready() -> void:
	get_tree().root.content_scale_size = Vector2i(480, 270)
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	DisplayServer.window_set_size(Vector2i(1440, 810))
	DisplayServer.window_set_position(Vector2i(240, 134))
	Backgrounds.init()

func _input(ev: InputEvent) -> void:
	if not (ev is InputEventKey and ev.pressed and not ev.echo): return
	var kc : int = ev.keycode
	
	if scene==Scene.GAME and kc==KEY_ESCAPE and not paused:
		paused=true 
		pause_cursor=0 
		queue_redraw() 
		return

	if paused and scene==Scene.GAME:
		match kc:
			KEY_UP,KEY_W,4194320:
				pause_cursor=(pause_cursor-1+4)%4 
				Sound.play_menu_move()
			KEY_DOWN,KEY_S,4194322:
				pause_cursor=(pause_cursor+1)%4
				Sound.play_menu_move()
			KEY_ESCAPE:
				paused=false
			KEY_SPACE,KEY_ENTER,4194309:
				Sound.play_menu_confirm()
				match pause_cursor:
					0: paused=false
					1: paused=false; game_active=false; Sound.stop_music(); Globals.reset_scores(); scene=Scene.MAIN_MENU
					2: get_tree().quit()
		queue_redraw() 
		return
	
	match scene:
		Scene.MAIN_MENU:
			if kc in [KEY_UP, KEY_W, 4194320]:
				main_menu_cursor = (main_menu_cursor - 1 + 2) % 2
				Sound.play_menu_move()
			elif kc in [KEY_DOWN, KEY_S, 4194322]:
				main_menu_cursor = (main_menu_cursor + 1) % 2
				Sound.play_menu_move()
			elif kc in [KEY_SPACE, KEY_ENTER, 4194309]:
				Sound.play_menu_confirm()
				Globals.player_count = 1 if main_menu_cursor == 0 else 2
				mode_cursor = 0
				scene = Scene.MODE_SELECT
		Scene.MODE_SELECT:
			if in_diff_select:
				if   kc in [KEY_UP, KEY_W, 4194320]:
					diff_cursor = (diff_cursor-1+4)%4
					Sound.play_menu_move()
				elif kc in [KEY_DOWN, KEY_S, 4194322]:
					diff_cursor = (diff_cursor+1)%4
					Sound.play_menu_move()
				elif kc in [KEY_SPACE, KEY_ENTER, 4194309]:
					Sound.play_menu_confirm()
					Globals.bot_difficulty = diff_cursor
					in_diff_select = false
					map_cursor = 11
					scene = Scene.MAP_SELECT
				elif kc == KEY_ESCAPE:
					Sound.play_menu_move()
					in_diff_select = false
			else:
				if   kc in [KEY_UP, KEY_W, 4194320]:
					mode_cursor = (mode_cursor - 1 + Globals.MODE_COUNT) % Globals.MODE_COUNT
					Sound.play_menu_move()
				elif kc in [KEY_DOWN, KEY_S, 4194322]:
					mode_cursor = (mode_cursor + 1) % Globals.MODE_COUNT
					Sound.play_menu_move()
				elif kc in [KEY_SPACE, KEY_ENTER, 4194309]:
					Sound.play_menu_confirm()
					Globals.selected_mode = mode_cursor
					if Globals.player_count == 1:
						diff_cursor = Globals.bot_difficulty
						in_diff_select = true
					else:
						map_cursor = 11
						scene = Scene.MAP_SELECT
				elif kc == KEY_ESCAPE:
					Sound.play_menu_move()
					scene = Scene.MAIN_MENU
		Scene.MAP_SELECT:
			if   kc in [KEY_LEFT,  4194319]:
				map_cursor = (map_cursor - 1 + 12) % 12
				Sound.play_menu_move()
			elif kc in [KEY_RIGHT, 4194321]:
				map_cursor = (map_cursor + 1) % 12
				Sound.play_menu_move()
			elif kc in [KEY_UP, 4194320]:
				if map_cursor >= 4:
					map_cursor -= 4
					Sound.play_menu_move()
			elif kc in [KEY_DOWN, 4194322]:
				if map_cursor < 8:
					map_cursor += 4
					Sound.play_menu_move()
			elif kc in [KEY_SPACE, KEY_ENTER, 4194309]:
				Sound.play_menu_confirm()
				if map_cursor == 11:
					Globals.forced_bg = -1
				else:
					Globals.forced_bg = map_cursor
				_start_game()
			elif kc == KEY_ESCAPE:
				Sound.play_menu_move()
				scene = Scene.MODE_SELECT
		Scene.ROUND_END:
			if kc in [KEY_SPACE,KEY_ENTER,4194309]: 
				round_end_timer=0.0
		Scene.MATCH_END:
			if kc in [KEY_SPACE,KEY_ENTER,KEY_ESCAPE,4194309]:
				Sound.stop_music() 
				Globals.reset_scores() 
				scene=Scene.MAIN_MENU

func _draw() -> void:
	match scene:
		Scene.MAIN_MENU:
			Backgrounds.draw(self, 0)
			Renderer.draw_main_menu(self, main_menu_cursor, menu_blink, menu_bob)
		Scene.MODE_SELECT:
			Backgrounds.draw(self, 0)
			Renderer.draw_mode_select(self, mode_cursor, menu_blink, menu_bob,
									  Globals.scores, Globals.player_count)
			if in_diff_select:
				Renderer.draw_diff_select(self, diff_cursor, menu_blink)
		Scene.MAP_SELECT:
			Backgrounds.draw(self, 0)
			Renderer.draw_map_select(self, map_cursor, menu_blink, menu_bob)
		Scene.GAME:
			_draw_game()
			if paused: 
				Renderer.draw_pause_menu(self, pause_cursor, menu_blink)
		Scene.ROUND_END:
			_draw_game()
			Renderer.draw_round_end(self, Globals.last_winner, Globals.scores, round_end_timer, Globals.player_count==1)
		Scene.MATCH_END:
			Backgrounds.draw(self,0)
			for p in particles:
				draw_rect(Rect2(p.pos.x-p.size, p.pos.y-p.size, p.size*2.0, p.size*2.0),
						  Color(p.color.r, p.color.g, p.color.b, clamp(p.life*2.0,0.0,1.0)))
			Renderer.draw_match_end(self, Globals.last_winner, Globals.scores, match_celebrate, Globals.player_count==1, Globals.match_stats)


func _in_rect(pos: Vector2, r: Rect2) -> bool:
	return pos.x >= r.position.x and pos.x <= r.position.x + r.size.x and \
		   pos.y >= r.position.y and pos.y <= r.position.y + r.size.y

func _draw_game() -> void:
	Backgrounds.draw(self, map_bg)

	if swap_flash_alpha > 0:
		var fc : Color = Globals.C_P1 if swap_flash_who == 0 else Globals.C_P2
		draw_rect(Rect2(0,0,Globals.VW,Globals.VH), Color(fc.r,fc.g,fc.b, swap_flash_alpha*0.35))
	if danger_flash > 0:
		draw_rect(Rect2(0,0,Globals.VW,Globals.VH), Color(1.0,0.4,0.1, danger_flash*0.45))

	var mode_str : String = "— %s —" % Globals.MODE_NAMES[Globals.selected_mode]
	draw_string(ThemeDB.fallback_font,
				Vector2(Globals.VW/2.0 - 30, 35.0),
				mode_str,
				HORIZONTAL_ALIGNMENT_CENTER, -1, 8,
				Color(1,1,1,0.25))

	if Globals.selected_mode == Globals.Mode.LAVA:
		Renderer.draw_lava(self, lava_y, lava_wave)

	if Globals.selected_mode == Globals.Mode.KING:
		var p1in : bool = _in_rect(players[0].pos, king_rect) and not players[0].dead
		var p2in : bool = _in_rect(players[1].pos, king_rect) and not players[1].dead
		Renderer.draw_king_zone(self, king_rect, p1in, p2in, king_time)

	for plat in platforms:
		Renderer.draw_platform(self, plat, map_bg, menu_bob)

	if gloves_alive: Renderer.draw_gloves_pickup(self, gloves_pos, gloves_bob)
	if boots_alive: Renderer.draw_boots_pickup(self, boots_pos, boots_bob)

	for i in range(players.size()):
		if not players[i].dead:
			Renderer.draw_player(self, players[i], map_bg)
			
	_draw_boids(self)
	
	for p in particles:
		draw_circle(p.pos, p.size, Color(p.color.r, p.color.g, p.color.b, clamp(p.life*2.5,0.0,1.0)))
		
	Renderer.draw_hud(self, Globals.scores, swap_charge, swap_ready,
					  Globals.selected_mode, chaos_timer, chaos_interval,
					  menu_blink, Globals.player_count==1, game_time, players)
					
	if announce_timer>0.0 and announce_text != "":
		Renderer.draw_announcement(self, announce_text, announce_timer, announce_color)
	Renderer.draw_visualizer(self)
	if Globals.debug_mode: 
		Renderer.draw_debug_overlay(self, players, platforms)
		
func _start_game() -> void:
	game_active = true
	game_time = 0.0
	particles.clear()
	platforms.clear()
	gloves_alive = false
	gloves_timer = randf_range(4.0, 10.0)
	boots_alive = false
	boots_timer = randf_range(8.0, 16.0)
	king_time = [0.0, 0.0]
	crumble_accum = 0.0
	swap_flash_alpha = 0.0
	chaos_timer = 0.0
	chaos_interval = randf_range(4.0, 6.0)
	announce_text = ""
	announce_timer = 0.0
	swap_charge = [0.0, 0.0]
	swap_ready = [false, false]
	danger_flash = 0.0
	Bot.reset()

	var map: Dictionary = Mapgen.generate(Globals.selected_mode)

	if Globals.forced_bg >= 0:
		map_bg = Globals.forced_bg
		map["bg"] = map_bg
	else:
		map_bg = map.get("bg", randi() % 11)

	_build_platforms(map)

	players = [
		_make_player(1, Vector2(float(map["p1"][0]), float(map["p1"][1]))),
		_make_player(2, Vector2(float(map["p2"][0]), float(map["p2"][1])))
	]

	match Globals.selected_mode:
		Globals.Mode.LAVA:
			lava_y = float(map.get("ls", 252.0))
			lava_speed = float(map.get("lspd", 4.0))
			lava_wave = 0.0
		Globals.Mode.KING:
			var z: Array = map["zone"]
			king_rect = Rect2(float(z[0]), float(z[1]), float(z[2]), float(z[3]))
			king_moves = map.get("zone_moves", false)
			king_move_dir = 1
		Globals.Mode.CRUMBLING:
			crumble_interval = 1.8

	scene = Scene.GAME

func _build_platforms(map: Dictionary) -> void:
	var key : String = "crumble_tiles" if "crumble_tiles" in map else "plats"
	if key in map:
		for p in map[key]:
			var h : float = p[3] if p.size() > 3 else 12.0
			platforms.append(_plat(float(p[0]), float(p[1]), float(p[2]), h))


func _plat(x: float, y: float, w: float, h: float = 12.0) -> Dictionary:
	return {"rect": Rect2(x - w/2.0, y - h/2.0, w, h),
			"alive": true, "shake": 0.0, "marked": false}


func _make_player(pid: int, sp: Vector2) -> Dictionary:
	return {
		"id": pid,
		"pos": sp,
		"vel": Vector2.ZERO,
		"dead": false,
		"push_cd": 0.0,
		"inv_time": 0.0,
		"flash": 0.0,
		"has_gloves": false,
		"has_boots": false,
		"on_floor": false,
		"face_blink": 0.0,
		"scale_x": 1.0,
		"scale_y": 1.0,
		"punch_anim": 0.0,
		"facing": 1,
		"was_on_floor": false,
		"walk_phase": 0.0
	}

func _update_game(delta: float) -> void:
	_update_swap(delta)
	if Globals.player_count==1:
		Bot.update(delta,players[1],players[0],platforms,
				   Globals.selected_mode,king_rect,lava_y,swap_ready[1])
	_update_players(delta)
	_update_mode(delta)
	_update_pickups(delta)

func _update_swap(delta: float) -> void:
	if Globals.selected_mode == Globals.Mode.CHAOS:
		chaos_timer += delta
		if chaos_timer >= chaos_interval:
			chaos_timer    = 0.0
			chaos_interval = randf_range(4.0, 7.0)
			_do_swap()
		return

	for i in 2:
		if not swap_ready[i]:
			swap_charge[i] = min(float(swap_charge[i]) + delta / SWAP_TIME, 1.0)
			if float(swap_charge[i]) >= 1.0:
				swap_ready[i] = true
				Sound.play_swap_ready()
				_announce("★ P%d: ОБМЕН ГОТОВ!" % (i + 1), 99.0)
				announce_color = Globals.C_P1 if i == 0 else Globals.C_P2

	if swap_ready[0] and Input.is_action_just_pressed("p1_swap"):
		_activate_swap(0)
	if swap_ready[1]:
		var trig : bool = Bot.get_swap_down() if Globals.player_count == 1 else Input.is_action_just_pressed("p2_swap")
		if trig: _activate_swap(1)

func _activate_swap(who: int) -> void:
	swap_charge[who] = 0.0
	swap_ready[who]  = false
	swap_flash_who   = who
	_do_swap()
	_announce("✦ P%d АКТИВИРОВАЛ ОБМЕН!" % (who + 1), 2.0)
	announce_color = Globals.C_P1 if who == 0 else Globals.C_P2

func _do_swap() -> void:
	var tmp_pos : Vector2 = players[0].pos
	players[0].pos = players[1].pos
	players[1].pos = tmp_pos
	players[0].vel = Vector2.ZERO
	players[1].vel = Vector2.ZERO
	_spawn_swap_fx(players[0].pos)
	_spawn_swap_fx(players[1].pos)
	swap_flash_alpha = 0.55
	Sound.play_swap()
	if Globals.selected_mode == Globals.Mode.CHAOS:
		Sound.play_chaos()
		_announce("⚡ ХАОС! ⚡", 1.0)
		announce_color = Color(1.0, 0.6, 0.2)

func _update_players(delta: float) -> void:
	for i in range(players.size()):
		if not players[i].dead:
			_update_player(players[i], delta, i)
			
func _update_mode(delta: float) -> void:
	match Globals.selected_mode:
		Globals.Mode.CRUMBLING: _update_crumble(delta)
		Globals.Mode.LAVA: _update_lava(delta)
		Globals.Mode.KING: _update_king(delta)
		
func _update_pickups(delta: float) -> void:
	gloves_bob += delta * 3.0
	boots_bob += delta * 2.5

	if not gloves_alive:
		gloves_timer += delta
		if gloves_timer >= GLOVES_INT:
			gloves_timer = 0.0
			gloves_alive = true
			gloves_pos = _pickup_pos()
	else:
		for p in players:
			if not p.dead and p.pos.distance_to(gloves_pos) < 22.0:
				p.has_gloves = true
				gloves_alive = false
				gloves_timer = randf_range(3.0, 8.0)
				Sound.play_pickup_glove()
				_announce("🥊 P%d — ПЕРЧАТКИ! Удар x2!" % p.id, 1.8)
				announce_color = Globals.C_GLOVE
				_spawn_pickup_fx(gloves_pos, Globals.C_GLOVE)
				Globals.match_stats.pickups[p.id-1]+=1

	if not boots_alive:
		boots_timer += delta
		if boots_timer >= BOOTS_INT:
			boots_timer = 0.0
			boots_alive = true
			boots_pos   = _pickup_pos()
	else:
		for p in players:
			if not p.dead and p.pos.distance_to(boots_pos) < 22.0:
				p.has_boots = true
				boots_alive = false
				boots_timer = randf_range(5.0, 12.0)
				Sound.play_pickup_boots()
				_announce("🥾 P%d — БОТИНКИ! Супер-прыжок!" % p.id, 1.8)
				announce_color = Globals.C_BOOTS
				_spawn_pickup_fx(boots_pos, Globals.C_BOOTS)
				Globals.match_stats.pickups[p.id-1]+=1

func _spawn_confetti() -> void:
	var cols : Array = [Globals.C_P1, Globals.C_P2, Globals.C_GLOVE, Globals.C_BOOTS, Color(1.0,0.38,0.82)]
	particles.append({"pos": Vector2(randf() * Globals.VW, -5.0),
		"vel": Vector2(randf_range(-28.0, 28.0), randf_range(38.0, 95.0)),
		"life": randf_range(2.0, 4.5),
		"color": cols[randi() % cols.size()],
		"size": randf_range(2.0, 5.0)})

func _announce(t: String, d: float) -> void:
	announce_text  = t
	announce_timer = d
	
func _spawn_swap_fx(pos: Vector2) -> void:
	for i in 16:
		var a : float = randf() * TAU
		var s : float = randf_range(30.0, 125.0)
		particles.append({"pos": Vector2(pos.x, pos.y),
			"vel": Vector2(cos(a)*s, sin(a)*s),
			"life": randf_range(0.3, 0.75),
			"color": Color(1.0, 1.0, randf_range(0.3, 1.0), 1.0),
			"size": randf_range(2.0, 4.5)})


func _update_player(p: Dictionary, delta: float, idx: int) -> void:
	if p.push_cd > 0: p.push_cd -= delta
	if p.inv_time > 0: p.inv_time -= delta
	if p.flash > 0: p.flash -= delta
	if p.punch_anim > 0: p.punch_anim -= delta
	p.face_blink += delta

	var pid : int=p.id
	var dir : float = _get_h(pid, idx)
	if dir != 0: p.facing = int(sign(dir))

	if p.inv_time > 0:
		p.vel.x = lerp(p.vel.x, 0.0, delta*2.5)
	else:
		p.vel.x = dir * Globals.SPEED

	if p.on_floor and abs(dir) > 0.1:
		p.walk_phase += delta * 8.0
	else:
		p.walk_phase = lerp(p.walk_phase, 0.0, delta * 10.0)
	Renderer.trail_add(p)

	if _get_jump(pid, idx) and p.on_floor:
		var jf : float = Globals.JUMP_FORCE * (Globals.JUMP_BOOTS_MULT if p.has_boots else 1.0)
		p.vel.y = jf
		p.scale_x = 0.65
		p.scale_y = 1.48
		if p.has_boots:
			p.has_boots = false
			_spawn_boots_fx(p.pos)
			Sound.play_super_jump()
			_announce("🥾 P%d — СУПЕР-ПРЫЖОК!" % p.id, 1.2)
			announce_color = Globals.C_BOOTS
		else:
			Sound.play_jump()

	if _get_push(pid, idx) and p.push_cd <= 0:
		_do_push(idx)
		p.push_cd = Globals.PUSH_CD
		p.punch_anim = 0.25

	p.vel.y += Globals.GRAVITY * delta
	p.scale_x = lerp(p.scale_x, 1.0, delta * 12.0)
	p.scale_y = lerp(p.scale_y, 1.0, delta * 12.0)
	p.pos += p.vel * delta

	p.was_on_floor = p.on_floor
	p.on_floor = false
	for plat in platforms:
		if not plat.alive: continue
		var r : Rect2 = plat.rect
		if p.pos.x + Globals.PW > r.position.x and p.pos.x - Globals.PW < r.position.x + r.size.x:
			if p.vel.y >= 0 and \
			   p.pos.y + Globals.PH > r.position.y and \
			   p.pos.y + Globals.PH < r.position.y + r.size.y + 14 and \
			   p.pos.y - Globals.PH < r.position.y:
				p.pos.y = r.position.y - Globals.PH
				p.vel.y = 0.0
				p.on_floor = true
				if not p.was_on_floor:
					p.scale_x = 1.32
					p.scale_y = 0.68
					Sound.play_land()

	if p.pos.y > Globals.VH + 55:
		_kill_player(idx)
	if p.pos.x < -55 or p.pos.x > Globals.VW + 55:
		_kill_player(idx)

func _update_crumble(delta: float) -> void:
	crumble_accum += delta
	if crumble_accum >= crumble_interval:
		crumble_accum = 0.0
		_remove_tile()
	for pl in platforms:
		if pl.shake > 0: pl.shake -= delta

func _update_lava(delta: float) -> void:
	lava_wave += delta * 2.0
	lava_y -= lava_speed * delta
	for i in range(players.size()):
		if not players[i].dead and players[i].pos.y + Globals.PH >= lava_y:
			_kill_player(i)

func _update_king(delta: float) -> void:
	if not game_active: return
	if king_moves:
		king_rect.position.x += float(king_move_dir) * 35.0 * delta
		if king_rect.position.x < 80.0:                              king_move_dir = 1
		if king_rect.position.x + king_rect.size.x > Globals.VW - 80.0: king_move_dir = -1
	var p1in : bool = _in_rect(players[0].pos, king_rect) and not players[0].dead
	var p2in : bool = _in_rect(players[1].pos, king_rect) and not players[1].dead
	if p1in and not p2in: king_time[0] += delta
	if p2in and not p1in: king_time[1] += delta
	if float(king_time[0]) >= Globals.KING_WIN_TIME: _end_round(1)
	elif float(king_time[1]) >= Globals.KING_WIN_TIME: _end_round(2)

func _pickup_pos() -> Vector2:
	var alive : Array = []
	for pl in platforms:
		if pl.alive: alive.append(pl)
	if alive.is_empty():
		return Vector2(randf_range(100.0, 380.0), 185.0)
	var pl : Dictionary = alive[randi() % alive.size()]
	var r : Rect2 = pl.rect
	return Vector2(
		r.get_center().x + randf_range(-r.size.x * 0.2, r.size.x * 0.2),
		r.position.y - 12.0)

const BOID_COUNT: int = 25
const BOID_ALIGN_R: float = 35.0
const BOID_COHES_R: float = 40.0
const BOID_SEPAR_R: float = 12.0
const BOID_W_ALIGN: float = 0.5
const BOID_W_COHES: float = 0.3
const BOID_W_SEPAR: float = 0.8
const BOID_MAX_SPD: float = 180.0


func _spawn_pickup_fx(pos: Vector2, col: Color) -> void:
	for i in 10:
		var a : float = randf() * TAU
		var s : float = randf_range(25.0, 80.0)
		particles.append({"pos": Vector2(pos.x, pos.y),
			"vel": Vector2(cos(a)*s, sin(a)*s - 30.0),
			"life": randf_range(0.3, 0.6),
			"color": col,
			"size": randf_range(2.0, 4.5)})

func _spawn_boids(pos: Vector2, col: Color) -> void:
	for i in BOID_COUNT:
		var a: float = randf() * TAU
		var spd: float = randf_range(25.0, 85.0)
		boids.append({
			"pos": Vector2(pos.x + randf_range(-6,6), pos.y + randf_range(-6,6)),
			"vel": Vector2(cos(a)*spd, sin(a)*spd - 45.0),
			"color": col,
			"life": randf_range(0.9, 1.8),
			"max_life": 1.5,
			"size": randf_range(2.2, 5.5),
		})


func _update_boids(delta: float) -> void:
	if boids.is_empty(): return
	for i in range(boids.size()-1, -1, -1):
		var b : Dictionary = boids[i]
		b.life -= delta
		if b.life <= 0: boids.remove_at(i); continue
		var bpos : Vector2 = b.pos
		var bvel : Vector2 = b.vel
		var align_sum : Vector2 = Vector2.ZERO
		var align_n : int = 0
		var cohes_sum : Vector2 = Vector2.ZERO
		var cohes_n : int = 0
		var separ_sum : Vector2 = Vector2.ZERO
		for j in boids.size():
			if j == i: continue
			var o : Dictionary = boids[j]
			var diff : Vector2 = o.pos - bpos
			var dist : float = diff.length()
			if dist < BOID_ALIGN_R:
				align_sum += o.vel; align_n += 1
			if dist < BOID_COHES_R:
				cohes_sum += o.pos; cohes_n += 1
			if dist < BOID_SEPAR_R and dist > 0.001:
				separ_sum -= diff.normalized()
		var steer : Vector2 = Vector2.ZERO
		if align_n > 0:
			var align_target : Vector2 = (align_sum / float(align_n)).normalized() * BOID_MAX_SPD
			steer += (align_target - bvel) * BOID_W_ALIGN
		if cohes_n > 0:
			var cohes_target : Vector2 = ((cohes_sum / float(cohes_n)) - bpos).normalized() * BOID_MAX_SPD
			steer += (cohes_target - bvel) * BOID_W_COHES
		steer += separ_sum * BOID_W_SEPAR * BOID_MAX_SPD
		bvel += Vector2(0, Globals.GRAVITY * 0.6) * delta
		bvel += steer * delta
		if bvel.length() > BOID_MAX_SPD:
			bvel = bvel.normalized() * BOID_MAX_SPD
		b.vel = bvel
		b.pos += bvel * delta

func _get_h(ctrl: int, idx: int) -> float:
	if Globals.player_count == 1 and idx == 1: return Bot.get_h()
	if Input.is_action_pressed("p%d_left"  % ctrl): return -1.0
	if Input.is_action_pressed("p%d_right" % ctrl): return  1.0
	return 0.0

func _get_jump(ctrl: int, idx: int) -> bool:
	if Globals.player_count == 1 and idx == 1: return Bot.get_jump_down(true)
	return Input.is_action_just_pressed("p%d_jump" % ctrl)

func _get_push(ctrl: int, idx: int) -> bool:
	if Globals.player_count == 1 and idx == 1: return Bot.get_push_down()
	return Input.is_action_just_pressed("p%d_push" % ctrl)

func _spawn_boots_fx(pos: Vector2) -> void:
	for i in 14:
		var a : float = randf() * TAU
		var s : float = randf_range(20.0, 100.0)
		particles.append({"pos": Vector2(pos.x, pos.y + 8.0),
			"vel": Vector2(cos(a)*s, -abs(sin(a))*s),
			"life": randf_range(0.3, 0.6),
			"color": Globals.C_BOOTS,
			"size": randf_range(2.0, 4.0)})

func _spawn_punch_fx(pos: Vector2, dir: int) -> void:
	for i in 10:
		var a : float = randf_range(-0.9, 0.9) + (0.0 if dir > 0 else PI)
		var s : float = randf_range(45.0, 115.0)
		particles.append({"pos": Vector2(pos.x + float(dir)*8.0, pos.y),
			"vel": Vector2(cos(a)*s, sin(a)*s - 22.0),
			"life": randf_range(0.18, 0.5),
			"color": Color(1.0, 0.72, 0.18, 1.0),
			"size": randf_range(1.5, 3.2)})


func _do_push(aidx: int) -> void:
	var att : Dictionary = players[aidx]
	var def_ : Dictionary = players[1 - aidx]
	if def_.dead or def_.inv_time > 0: return
	
	var dist_vec : Vector2 = def_.pos - att.pos
	var dist_x : float = abs(dist_vec.x)
	var dist_y : float = abs(dist_vec.y)
	
	if dist_x >= 65 or dist_y >= 50: return
	
	var is_enemy_in_front : bool = false
	if att.facing == 1:
		if def_.pos.x > att.pos.x:
			is_enemy_in_front = true
	else:
		if def_.pos.x < att.pos.x:
			is_enemy_in_front = true
	
	if not is_enemy_in_front:
		return

	var force : float = Globals.PUSH_FORCE
	if att.has_gloves:
		force *= Globals.PUSH_GLOVE_MULT
		att.has_gloves = false
		danger_flash = 0.6
		Sound.play_push_glove()
		_announce("💥 МОЩНЫЙ УДАР!", 1.0)
		announce_color = Color(1.0, 0.5, 0.1)
	else:
		Sound.play_push()

	var pd : float = sign(dist_vec.x)
	if pd == 0: pd = float(att.facing)

	def_.vel.x = pd * force
	def_.vel.y = -Globals.PUSH_UP
	def_.inv_time = 0.5
	def_.flash = 0.5
	def_.scale_x = 1.65
	def_.scale_y = 0.48
	_spawn_punch_fx(att.pos + Vector2(float(att.facing) * 12.0, 0.0), att.facing)
	Globals.match_stats.hits[aidx]+=1

func _kill_player(idx: int) -> void:
	if players[idx].dead: return
	players[idx].dead = true
	var col : Color = Globals.C_P1 if players[idx].id == 1 else Globals.C_P2
	_spawn_boids(players[idx].pos, col)
	Backgrounds.on_death(col)
	Sound.play_death()
	Globals.match_stats.deaths[idx]+=1	
	_end_round(2 if idx == 0 else 1)


func _remove_tile() -> void:
	var alive : Array = []
	for i in range(platforms.size()):
		if platforms[i].alive and not platforms[i].marked:
			alive.append(i)
	if alive.is_empty(): return
	var idx : int = alive[randi() % alive.size()]
	platforms[idx].marked = true
	platforms[idx].shake = 0.5
	Sound.play_crumble()
	var pl : Dictionary = platforms[idx]
	get_tree().create_timer(0.5).timeout.connect(func() -> void: pl.alive = false)

func _end_round(winner: int) -> void:
	if not game_active: return
	game_active = false
	Globals.last_winner = winner
	Globals.scores[winner - 1] += 1
	if Globals.scores[winner-1] >= WIN_SCORE:
		Sound.play_match_win()
		await get_tree().create_timer(1.0).timeout
		match_celebrate = 0.0 
		scene=Scene.MATCH_END
	else:
		round_end_timer = 2.5 
		scene=Scene.ROUND_END
		
func _draw_boids(c:Node2D)->void:
	for b in boids:
		var a : float=clamp(b.life/float(b.max_life)*2.5, 0.0, 1.0)
		c.draw_circle(b.pos, float(b.size)*a, Color(b.color.r, b.color.g, b.color.b, a))
