extends Node2D

enum Scene { MAIN_MENU, MODE_SELECT, MAP_SELECT, GAME, RESULT }
var scene            : int   = Scene.MAIN_MENU
var main_menu_cursor : int   = 0
var mode_cursor      : int   = 0
var map_cursor       : int   = 11
var game_active      : bool  = false

var players     : Array = []
var controllers : Array = [1, 2]

var swap_charge     : Array = [0.0, 0.0]
var swap_ready      : Array = [false, false]
const SWAP_TIME     : float = 15.0
var swap_flash_alpha : float = 0.0
var swap_flash_who   : int   = 0

var chaos_timer    : float = 0.0
var chaos_interval : float = 4.0

var platforms : Array = []
var map_bg    : int   = 0

var gloves_pos   : Vector2 = Vector2.ZERO
var gloves_alive : bool    = false
var gloves_bob   : float   = 0.0
var gloves_timer : float   = 0.0
const GLOVES_INT : float   = 22.0

var boots_pos    : Vector2 = Vector2.ZERO
var boots_alive  : bool    = false
var boots_bob    : float   = 0.0
var boots_timer  : float   = 0.0
const BOOTS_INT  : float   = 28.0

var lava_y     : float = 999.0
var lava_wave  : float = 0.0
var lava_speed : float = 4.0

var king_rect     : Rect2 = Rect2(0,0,0,0)
var king_time     : Array = [0.0, 0.0]
var king_move_dir : int   = 1
var king_moves    : bool  = false

var crumble_accum    : float = 0.0
var crumble_interval : float = 1.8

var menu_bob   : float = 0.0
var menu_blink : float = 0.0
var game_time  : float = 0.0

var announce_text  : String = ""
var announce_timer : float  = 0.0
var announce_color : Color  = Globals.C_GOLD

var result_celebrate : float = 0.0
var particles        : Array = []
var danger_flash     : float = 0.0

const WIN_SCORE : int = 3

var boids : Array = []

var diff_cursor      : int  = 1
var in_diff_select   : bool = false


func _process(delta: float) -> void:
	if has_node("/root/Renderer"):
		get_node("/root/Renderer").update(delta)
	
	queue_redraw()

func _ready() -> void:
	get_tree().root.content_scale_size   = Vector2i(480, 270)
	get_tree().root.content_scale_mode   = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	DisplayServer.window_set_size(Vector2i(1440, 810))
	DisplayServer.window_set_position(Vector2i(240, 134))
	Backgrounds.init()

func _input(event: InputEvent) -> void:
	if scene == Scene.MAIN_MENU:
		if event.is_action_pressed("ui_down") or (event is InputEventKey and event.pressed and event.keycode == KEY_S):
			main_menu_cursor = 1
		elif event.is_action_pressed("ui_up") or (event is InputEventKey and event.pressed and event.keycode == KEY_W):
			main_menu_cursor = 0
			
		if event.is_action_pressed("ui_accept"):
			scene = Scene.MODE_SELECT

	elif scene == Scene.MODE_SELECT:
		if event.is_action_pressed("ui_down") or (event is InputEventKey and event.pressed and event.keycode == KEY_S):
			if mode_cursor < 4:
				mode_cursor += 1
		elif event.is_action_pressed("ui_up") or (event is InputEventKey and event.pressed and event.keycode == KEY_W):
			if mode_cursor > 0:
				mode_cursor -= 1
				
		if event.is_action_pressed("ui_accept"):
			scene = Scene.MAP_SELECT
		elif event.is_action_pressed("ui_cancel"):
			scene = Scene.MAIN_MENU

	elif scene == Scene.MAP_SELECT:
		if event.is_action_pressed("ui_down") or (event is InputEventKey and event.pressed and event.keycode == KEY_S):
			if map_cursor < 11: map_cursor += 1
		elif event.is_action_pressed("ui_up") or (event is InputEventKey and event.pressed and event.keycode == KEY_W):
			if map_cursor > 0: map_cursor -= 1
			
		if event.is_action_pressed("ui_accept"):
			_start_match()
		elif event.is_action_pressed("ui_cancel"):
			scene = Scene.MODE_SELECT

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
		Scene.RESULT:
			Backgrounds.draw(self, 0)
			for p in particles:
				draw_rect(
					Rect2(p.pos.x - p.size, p.pos.y - p.size, p.size * 2.0, p.size * 2.0),
					Color(p.color.r, p.color.g, p.color.b, clamp(p.life * 2.0, 0.0, 1.0)))
			Renderer.draw_result(self, Globals.last_winner, Globals.scores,
								 result_celebrate, Globals.player_count == 1)


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
				Vector2(Globals.VW/2.0, 28.0),
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
	if boots_alive:  Renderer.draw_boots_pickup(self, boots_pos,  boots_bob)

	for i in range(players.size()):
		if not players[i].dead:
			Renderer.draw_player(self, players[i], map_bg)


func _start_match() -> void:
	var map_data : Dictionary = Mapgen.generate(Globals.selected_mode)
	
	map_bg = map_data["bg"]
	platforms.clear()
	
	var raw_plats : Array = map_data.get("plats", map_data.get("crumble_tiles", []))
	
	for p in raw_plats:
		var cx: float = p[0]
		var cy: float = p[1]
		var w: float = p[2]
		var h: float = p[3]
		
		var rect := Rect2(cx - w/2.0, cy - h/2.0, w, h)
		
		platforms.append({
			"rect": rect,
			"alive": true,
			"shake": 0.0,
			"marked": false
		})
	
	if Globals.selected_mode == 2:
		lava_y = map_data.get("ls", 250.0)
		lava_speed = map_data.get("lspd", 5.0)
		
	scene = Scene.GAME
