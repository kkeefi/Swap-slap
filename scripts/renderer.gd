extends Node

var time : float = 0.0
func update(delta: float) -> void: time += delta

const BG_NAMES : Array = [
	"КОСМОС","НЕБО","ВУЛКАН","ПЕЩЕРА","НЕОН",
	"ЗАКАТ","ПОДВОДНЫЙ МИР","ЛЕС","ШТОРМ","ТУНДРА","ПУСТЫНЯ"
]
const BG_ICONS : Array = ["🌌","☁️","🌋","⛏️","💡","🌅","🌊","🌿","⛈️","❄️","🏜️"]

func draw_main_menu(c: Node2D, cursor: int, blink: float, bob: float) -> void:
	var font : Font  = ThemeDB.fallback_font
	var VW   : float = Globals.VW
	var VH   : float = Globals.VH
	var ty   : float = 48.0 + sin(bob*1.6)*4.0

	c.draw_string(font, Vector2(VW/2, ty+2),
				  "SWAP & SLAP", HORIZONTAL_ALIGNMENT_CENTER, -1, 26, Color(0,0,0,0.55))
	c.draw_string(font, Vector2(VW/2, ty),
				  "SWAP & SLAP", HORIZONTAL_ALIGNMENT_CENTER, -1, 26, Globals.C_GOLD)
	c.draw_string(font, Vector2(VW/2, ty+17),
				  "Меняй тела · Толкай врага · Побеждай!",
				  HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.62,0.72,0.85))
	c.draw_line(Vector2(55,ty+27), Vector2(VW-55,ty+27),
				Color(Globals.C_GOLD.r,Globals.C_GOLD.g,Globals.C_GOLD.b,0.32), 1.0)

	var btns : Array = [["👤  1 ИГРОК",Globals.C_P1],["👥  2 ИГРОКА",Globals.C_P2]]
	var bw : float = 156.0; var bh : float = 30.0
	for i in 2:
		var sel : bool  = i == cursor
		var bx  : float = VW/2.0 - bw/2.0
		var by_ : float = 108.0 + float(i)*42.0
		c.draw_rect(Rect2(bx+2,by_+2,bw,bh), Color(0,0,0,0.45))
		c.draw_rect(Rect2(bx,by_,bw,bh), Color(0.18,0.28,0.48,0.92) if sel else Color(0.07,0.07,0.14,0.88))
		var bc : Color = btns[i][1] as Color
		c.draw_rect(Rect2(bx,by_,bw,bh), Color(bc.r,bc.g,bc.b, 0.72+abs(sin(blink*4))*0.28 if sel else 0.30), false, 1.5)
		c.draw_string(font, Vector2(VW/2, by_+19),
					  btns[i][0] as String, HORIZONTAL_ALIGNMENT_CENTER, -1, 11,
					  Color.WHITE if sel else Color(0.55,0.55,0.65))
		if sel:
			c.draw_string(font, Vector2(bx-12+sin(blink*5)*2, by_+19),
						  "►", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Globals.C_GOLD)

	c.draw_line(Vector2(38,VH-18), Vector2(VW-38,VH-18), Color(0.15,0.15,0.28,0.4), 0.5)
	c.draw_string(font, Vector2(VW/2-95, VH-10),
				  "W/S ↑↓ — выбор    Пробел/Enter — подтвердить",
				  HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.30,0.30,0.40))


func draw_mode_select(c: Node2D, cursor: int, blink: float, bob: float,
					  scores: Array, player_count: int) -> void:
	var font : Font  = ThemeDB.fallback_font
	var VW   : float = Globals.VW
	var VH   : float = Globals.VH
	var ty   : float = 8.0 + sin(bob*1.5)*2.0

	c.draw_string(font, Vector2(VW/2, ty+18+2),
				  "SWAP & SLAP", HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color(0,0,0,0.55))
	c.draw_string(font, Vector2(VW/2, ty+18),
				  "SWAP & SLAP", HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Globals.C_GOLD)

	var lc : Color = Globals.C_P1 if player_count==1 else Globals.C_P2
	c.draw_string(font, Vector2(VW-4, 13),
				  "%s" % ("1 ИГРОК" if player_count==1 else "2 ИГРОКА"),
				  HORIZONTAL_ALIGNMENT_RIGHT, -1, 7, Color(lc.r,lc.g,lc.b,0.82))

	c.draw_line(Vector2(35,ty+28), Vector2(VW-35,ty+28),
				Color(Globals.C_GOLD.r,Globals.C_GOLD.g,Globals.C_GOLD.b,0.28), 1.0)

	for i in Globals.MODE_COUNT:
		var sel : bool  = i == cursor
		var my  : float = ty + 37.0 + float(i)*26.0
		if sel:
			c.draw_rect(Rect2(30, my-1, VW-60, 21),
						Color(1,1,0, 0.08+abs(sin(blink*4))*0.06))
			c.draw_line(Vector2(32,my-1), Vector2(VW-32,my-1), Color(1,1,0,0.25), 0.5)
			c.draw_line(Vector2(32,my+20), Vector2(VW-32,my+20), Color(1,1,0,0.15), 0.5)
			c.draw_string(font, Vector2(42+sin(blink*5)*2, my+13),
						  "►", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Globals.C_GOLD)
			c.draw_string(font, Vector2(60, my+13),
						  Globals.MODE_ICONS[i]+"  "+Globals.MODE_NAMES[i],
						  HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Globals.C_GOLD)
		else:
			c.draw_string(font, Vector2(60, my+13),
						  Globals.MODE_ICONS[i]+"  "+Globals.MODE_NAMES[i],
						  HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.45,0.45,0.60))

	var dy : float = ty + 37.0 + float(Globals.MODE_COUNT)*26.0 + 4.0
	c.draw_rect(Rect2(32, dy, VW-64, 22), Color(0.05,0.07,0.14,0.90))
	c.draw_rect(Rect2(32, dy, VW-64, 22), Color(0.20,0.22,0.40,0.35), false, 1.0)
	c.draw_string(font, Vector2(46, dy+14),
				  Globals.MODE_DESCS[cursor].get_slice("\n",0),
				  HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.55,0.80,0.60))

	if scores[0]>0 or scores[1]>0:
		c.draw_string(font, Vector2(VW-4, VH-12),
					  "P1:%d  P2:%d" % [scores[0],scores[1]],
					  HORIZONTAL_ALIGNMENT_RIGHT, -1, 8, Color(0.45,0.45,0.55))

	c.draw_line(Vector2(35,VH-20), Vector2(VW-35,VH-20), Color(0.15,0.15,0.28,0.38), 0.5)
	c.draw_string(font, Vector2(VW/2, VH-10),
				  "W/S ↑↓ — выбор   Пробел/Enter — далее   ESC — назад",
				  HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.30,0.30,0.40))


func draw_map_select(c: Node2D, cursor: int, blink: float, _bob: float) -> void:
	var font  : Font  = ThemeDB.fallback_font
	var VW    : float = Globals.VW
	var VH    : float = Globals.VH

	c.draw_rect(Rect2(0,0,VW,VH), Color(0,0,0,0.42))

	c.draw_string(font, Vector2(VW/2, 16),
				  "ВЫБОР КАРТЫ", HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Globals.C_GOLD)
	c.draw_line(Vector2(24,21), Vector2(VW-24,21),
				Color(Globals.C_GOLD.r,Globals.C_GOLD.g,Globals.C_GOLD.b,0.28), 1.0)

	var map_name : String = "СЛУЧАЙНАЯ 🎲" if cursor==11 else BG_NAMES[cursor]
	c.draw_string(font, Vector2(VW/2, 33),
				  map_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Globals.C_GOLD)


	const COLS  : int   = 4
	const ROWS  : int   = 3
	const CW    : float = 60.0
	const CH    : float = 45.0
	const GAP   : float = 4.0
	const PAD_T : float = 40.0

	var grid_w : float = float(COLS)*(CW+GAP) - GAP
	var grid_h : float = float(ROWS)*(CH+GAP) - GAP
	var ox     : float = (VW - grid_w) / 2.0
	var oy     : float = PAD_T

	for idx in 12:
		var col : int   = idx % COLS
		var row : int   = idx / COLS
		var cx  : float = ox + float(col) * (CW + GAP)
		var cy  : float = oy + float(row) * (CH + GAP)

		if idx == 11:
			_draw_rand_cell(c, font, cx, cy, CW, CH, idx==cursor, blink)
		else:
				_draw_map_preview(c, font, cx, cy, CW, CH, idx, idx==cursor, blink)

	c.draw_line(Vector2(20,VH-16), Vector2(VW-20,VH-16), Color(0.18,0.18,0.30,0.38), 0.5)
	c.draw_string(font, Vector2(VW/2, VH-7),
				  "←→↑↓ — выбор    Пробел/Enter — подтвердить    ESC — назад",
				  HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.30,0.30,0.42))


func _draw_map_preview(c: Node2D, font: Font, x: float, y: float,
					   w: float, h: float, bg_id: int, selected: bool, blink: float) -> void:
	var sel_col : Color = Globals.C_GOLD if selected else Color(0.25,0.28,0.45,0.6)
	c.draw_rect(Rect2(x, y, w, h), Color(0,0,0,0.55))
	c.draw_rect(Rect2(x, y, w, h), sel_col, false, 1.5 if selected else 0.8)
	if selected:
		var pulse : float = abs(sin(blink*4))*0.15
		c.draw_rect(Rect2(x, y, w, h),
					Color(Globals.C_GOLD.r,Globals.C_GOLD.g,Globals.C_GOLD.b,0.08+pulse))

	var pw : float = w - 6.0
	var ph : float = h - 16.0
	var px : float = x + 3.0
	var py_ : float = y + 3.0

	var bg_colors : Array = [
		Color(0.02,0.02,0.06),  # 0 космос
		Color(0.52,0.75,0.92),  # 1 небо
		Color(0.15,0.06,0.02),  # 2 вулкан
		Color(0.10,0.06,0.15),  # 3 пещера
		Color(0.02,0.01,0.10),  # 4 неон
		Color(0.78,0.38,0.08),  # 5 закат
		Color(0.04,0.15,0.35),  # 6 подводный
		Color(0.08,0.18,0.04),  # 7 лес
		Color(0.12,0.12,0.18),  # 8 шторм
		Color(0.70,0.78,0.88),  # 9 тундра
		Color(0.62,0.48,0.22),  # 10 пустыня
	]
	c.draw_rect(Rect2(px, py_, pw, ph), bg_colors[bg_id])

	match bg_id:
		0:  # космос
			c.draw_circle(Vector2(px+pw*0.75, py_+ph*0.25), 5, Color(0.8,0.8,0.7))
			for i in 4:
				var sx := px + float(i*9 % int(pw))
				var sy := py_ + float((i*13) % int(ph))
				c.draw_circle(Vector2(sx, sy), 1.0, Color(1,1,1,0.5))
		1:  # небо
			c.draw_circle(Vector2(px+pw*0.3, py_+ph*0.3), 6, Color(1,1,1,0.6))
			c.draw_circle(Vector2(px+pw*0.5, py_+ph*0.3), 5, Color(1,1,1,0.6))
		2:  # вулкан
			c.draw_rect(Rect2(px, py_+ph*0.7, pw, ph*0.3), Color(0.88,0.35,0.05,0.8))
			c.draw_colored_polygon(PackedVector2Array([
				Vector2(px+pw*0.5, py_+ph*0.1),
				Vector2(px+pw*0.3, py_+ph*0.7),
				Vector2(px+pw*0.7, py_+ph*0.7)
			]), Color(0.25,0.12,0.05))
		3:  # пещера
			c.draw_colored_polygon(PackedVector2Array([
				Vector2(px, py_), Vector2(px+pw*0.15, py_+ph*0.45),
				Vector2(px+pw*0.35, py_+ph*0.3), Vector2(px+pw*0.5, py_+ph*0.5),
				Vector2(px+pw*0.7, py_+ph*0.25), Vector2(px+pw, py_+ph*0.4),
				Vector2(px+pw, py_)
			]), Color(0.18,0.12,0.25))
		4:  # неон
			c.draw_line(Vector2(px,py_+ph*0.5), Vector2(px+pw,py_+ph*0.5), Color(0.1,0.8,1.0,0.7), 1.0)
			c.draw_circle(Vector2(px+pw*0.5, py_+ph*0.5), 4, Color(0.2,1.0,1.0,0.8))
		5:  # закат
			c.draw_rect(Rect2(px, py_, pw, ph*0.6), Color(0.92,0.55,0.15))
			c.draw_rect(Rect2(px, py_+ph*0.6, pw, ph*0.4), Color(0.55,0.30,0.10))
			c.draw_circle(Vector2(px+pw*0.6, py_+ph*0.35), 6, Color(1,0.85,0.2,0.9))
		6:  # подводный
			c.draw_rect(Rect2(px, py_, pw, ph*0.15), Color(0.05,0.2,0.5))
			c.draw_rect(Rect2(px, py_+ph*0.15, pw, ph*0.85), Color(0.04,0.18,0.42))
			for i in 3:
				c.draw_circle(Vector2(px+pw*(0.2+float(i)*0.3), py_+ph*0.4), 2, Color(0.5,0.8,1.0,0.5))
		7:  # лес
			c.draw_rect(Rect2(px, py_+ph*0.6, pw, ph*0.4), Color(0.12,0.22,0.06))
			for i in 3:
				var tx := px + pw*(0.2+float(i)*0.3)
				c.draw_rect(Rect2(tx-1.5, py_+ph*0.45, 3, ph*0.2), Color(0.28,0.18,0.08))
				c.draw_colored_polygon(PackedVector2Array([
					Vector2(tx, py_+ph*0.1), Vector2(tx-5, py_+ph*0.45), Vector2(tx+5, py_+ph*0.45)
				]), Color(0.2,0.45,0.12))
		8:  # шторм
			c.draw_rect(Rect2(px, py_, pw, ph), Color(0.18,0.18,0.26))
			c.draw_line(Vector2(px+pw*0.6, py_+2), Vector2(px+pw*0.45, py_+ph*0.45),
						Color(1,0.95,0.3,0.9), 1.5)
		9:  # тундра
			c.draw_rect(Rect2(px, py_+ph*0.55, pw, ph*0.45), Color(0.82,0.88,0.92))
			c.draw_colored_polygon(PackedVector2Array([
				Vector2(px, py_+ph*0.55), Vector2(px+pw*0.3, py_+ph*0.12), Vector2(px+pw*0.6, py_+ph*0.55)
			]), Color(0.60,0.68,0.78))
		10: # пустыня
			c.draw_rect(Rect2(px, py_, pw, ph*0.55), Color(0.80,0.62,0.28))
			c.draw_colored_polygon(PackedVector2Array([
				Vector2(px, py_+ph), Vector2(px+pw*0.4, py_+ph*0.55),
				Vector2(px+pw*0.8, py_+ph*0.75), Vector2(px+pw, py_+ph*0.6), Vector2(px+pw, py_+ph)
			]), Color(0.72,0.55,0.22))
			c.draw_circle(Vector2(px+pw*0.75, py_+ph*0.2), 6, Color(1,0.88,0.2))

	var name_col : Color = Globals.C_GOLD if selected else Color(0.65,0.65,0.72)
	c.draw_string(font, Vector2(x+w/2-15, y+h-5), BG_NAMES[bg_id],
				  HORIZONTAL_ALIGNMENT_LEFT, -1, 6, name_col)

func _draw_rand_cell(c: Node2D, font: Font, x: float, y: float,
					 w: float, h: float, selected: bool, blink: float) -> void:
	var col : Color = Globals.C_GOLD if selected else Color(0.48,0.48,0.62)
	var pulse : float = abs(sin(blink*4))*0.18 if selected else 0.0
	c.draw_rect(Rect2(x,y,w,h), Color(0.08,0.08,0.16))
	c.draw_rect(Rect2(x,y,w,h), Color(col.r,col.g,col.b,0.12+pulse))
	c.draw_rect(Rect2(x,y,w,h), col, false, 1.5 if selected else 0.8)
	c.draw_string(font, Vector2(x+w/2, y+20), "🎲",
				  HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.WHITE)
	c.draw_string(font, Vector2(x+w/2, y+h-6), "РАНДОМ",
				  HORIZONTAL_ALIGNMENT_CENTER, -1, 6, col)
