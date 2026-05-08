extends Node2D

enum Scene { MAIN_MENU, MODE_SELECT, MAP_SELECT, GAME }
var scene : int = Scene.MAIN_MENU

var main_menu_cursor : int = 0
var mode_cursor      : int = 0
var map_cursor       : int = 11

var scores       : Array = [0, 0]
var player_count : int = 1

func _process(delta: float) -> void:
	if has_node("/root/Renderer"):
		get_node("/root/Renderer").update(delta)
	
	queue_redraw()

func _input(event: InputEvent) -> void:
	if scene == Scene.MAIN_MENU:
		if event.is_action_pressed("ui_down") or (event is InputEventKey and event.pressed and event.keycode == KEY_S):
			main_menu_cursor = 1
		elif event.is_action_pressed("ui_up") or (event is InputEventKey and event.pressed and event.keycode == KEY_W):
			main_menu_cursor = 0
			
		if event.is_action_pressed("ui_accept"):
			player_count = 1 if main_menu_cursor == 0 else 2
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
			scene = Scene.GAME
		elif event.is_action_pressed("ui_cancel"):
			scene = Scene.MODE_SELECT

func _draw() -> void:
	var r = get_node("/root/Renderer")
	
	match scene:
		Scene.MAIN_MENU:
			r.draw_main_menu(self, main_menu_cursor, r.time, r.time)
			
		Scene.MODE_SELECT:
			r.draw_mode_select(self, mode_cursor, r.time, r.time, scores, player_count)
			
		Scene.MAP_SELECT:
			r.draw_map_select(self, map_cursor, r.time, r.time)
			
		Scene.GAME:
			draw_string(ThemeDB.fallback_font, Vector2(150, 130), "ТУТ БУДЕТ ИГРА", HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
