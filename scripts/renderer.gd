extends Node

var time : float = 0.0
func update(delta: float) -> void: time += delta

const BG_NAMES : Array = [
	"КОСМОС","НЕБО","ВУЛКАН","ПЕЩЕРА","НЕОН",
	"ЗАКАТ","ОКЕАН","ЛЕС","ШТОРМ","ТУНДРА","ПУСТЫНЯ"
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
		Color(0.04,0.15,0.35),  # 6 океан
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
		6:  # океан
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


func _badge_glove(c: Node2D, px: float, py: float) -> void:
	c.draw_circle(Vector2(px, py), 5.5, Globals.C_GLOVE)
	c.draw_circle(Vector2(px+3.5, py-2.5), 2.2, Globals.C_GLOVE)
	c.draw_rect(Rect2(px-3.5, py+1.5, 7, 3.5), Color(0.72,0.22,0.12))

func _badge_boots(c: Node2D, px: float, py: float) -> void:
	c.draw_rect(Rect2(px-4, py-2, 9, 6.5), Color(0.08,0.08,0.08))
	c.draw_rect(Rect2(px-3.5, py-6, 8, 5.5), Globals.C_BOOTS)


func draw_gloves_pickup(c: Node2D, pos: Vector2, bob: float) -> void:
	var gp : Vector2 = pos + Vector2(0, sin(bob)*4)
	var r  : float   = 9.0
	c.draw_circle(gp, r*2.0, Color(Globals.C_GLOVE.r,Globals.C_GLOVE.g,Globals.C_GLOVE.b,0.15))
	c.draw_circle(Vector2(gp.x, gp.y), r*0.9, Globals.C_GLOVE)
	c.draw_circle(Vector2(gp.x+r*0.7, gp.y-r*0.5), r*0.42, Globals.C_GLOVE)
	c.draw_rect(Rect2(gp.x-r*0.7, gp.y+r*0.3, r*1.4, r*0.7), Color(0.72,0.22,0.12))
	c.draw_string(ThemeDB.fallback_font, Vector2(gp.x, gp.y-r*1.6),
				  "ПЕРЧАТКИ", HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color(1,0.9,0.3,0.9))

func draw_boots_pickup(c: Node2D, pos: Vector2, bob: float) -> void:
	var gp : Vector2 = pos + Vector2(0, sin(bob*0.9)*4)
	var r  : float   = 9.0
	c.draw_circle(gp, r*2.0, Color(Globals.C_BOOTS.r,Globals.C_BOOTS.g,Globals.C_BOOTS.b,0.15))
	c.draw_rect(Rect2(gp.x-r*0.88, gp.y+r*0.42, r*1.76, r*0.58), Color(0.12,0.12,0.12))
	c.draw_rect(Rect2(gp.x-r*0.78, gp.y-r*0.52, r*1.4, r*0.98), Globals.C_BOOTS)
	c.draw_string(ThemeDB.fallback_font, Vector2(gp.x, gp.y-r*1.6),
				  "БОТИНКИ", HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color(0.4,1,0.6,0.9))


func draw_player(c: Node2D, p: Dictionary, _bg: int) -> void:
	if p.dead: return
	if p.flash > 0 and int(p.flash * 10) % 2 == 0: return

	var px  : float = p.pos.x
	var py  : float = p.pos.y
	var w   : float = Globals.PW * p.scale_x
	var h   : float = Globals.PH * p.scale_y
	var col : Color = Globals.C_P1 if p.id == 1 else Globals.C_P2
	var drk : Color = col.darkened(0.32)


	Globals.draw_ellipse(c, Vector2(px, py+h+2), w*0.78, 2.5, Color(0,0,0,0.38))

	c.draw_rect(Rect2(px-w, py-h, w*2, h*2), col)
	c.draw_rect(Rect2(px-w, py,   w*2, h),   drk)
	c.draw_rect(Rect2(px-w+1, py-h+1, w*0.6, h*0.25), Color(1,1,1,0.18))

	_draw_face(c, px, py, p)

	if p.get("has_gloves", false):
		_badge_glove(c, px, py-h-3)
	if p.get("has_boots", false):
		_badge_boots(c, px+12, py-h-3)

	c.draw_string(ThemeDB.fallback_font, Vector2(px-5, py-h-12),
				  "P%d" % p.id, HORIZONTAL_ALIGNMENT_LEFT, -1, 7,
				  col.lightened(0.3))

	if p.punch_anim > 0:
		var t   : float = p.punch_anim / 0.25
		var pax : float = px + float(p.facing) * (w + 5)
		c.draw_circle(Vector2(pax, py-2), 6*t, Color(1,0.85,0.2,t*3.5))
		for i in 5:
			var a  : float = float(i)*TAU/5.0 + time*8.0
			c.draw_line(Vector2(pax+cos(a)*4*t, py-2+sin(a)*4*t),
						Vector2(pax+cos(a)*8*t, py-2+sin(a)*8*t),
						Color(1,1,0.5,t*2.5), 1.5)

func _draw_face(c: Node2D, px: float, py: float, p: Dictionary) -> void:
	var w     : float = Globals.PW * p.scale_x
	var h     : float = Globals.PH * p.scale_y
	var eo    : float = float(p.facing) * 1.0
	var blink : bool  = int(p.face_blink * 0.7) % 8 == 0
	if not blink:
		c.draw_rect(Rect2(px-w*0.55+eo, py-h*0.45, w*0.3, h*0.22), Color.WHITE)
		c.draw_rect(Rect2(px+w*0.1+eo,  py-h*0.45, w*0.3, h*0.22), Color.WHITE)
		c.draw_rect(Rect2(px-w*0.45+eo+float(p.facing), py-h*0.4, w*0.15, h*0.15), Color(0.08,0.04,0.1))
		c.draw_rect(Rect2(px+w*0.2+eo+float(p.facing),  py-h*0.4, w*0.15, h*0.15), Color(0.08,0.04,0.1))
	else:
		c.draw_line(Vector2(px-w*0.55+eo, py-h*0.38), Vector2(px-w*0.25+eo, py-h*0.38), Color.WHITE, 1.5)
		c.draw_line(Vector2(px+w*0.1+eo,  py-h*0.38), Vector2(px+w*0.4+eo,  py-h*0.38), Color.WHITE, 1.5)
	var near_edge : bool = p.pos.x < 70 or p.pos.x > Globals.VW - 70
	if near_edge:
		c.draw_arc(Vector2(px+eo*0.5, py+h*0.1), 3, 0, PI, 8, Color(0.08,0.04,0.04), 1.0)
	else:
		c.draw_arc(Vector2(px+eo*0.5, py+h*0.05), 3, PI, TAU, 8, Color(0.08,0.04,0.04), 1.0)


func draw_platform(c: Node2D, plat: Dictionary, map_bg: int, anim_time: float) -> void:
	if not plat.alive: return
	var r  : Rect2 = plat.rect
	var sx : float = sin(anim_time*20)*plat.shake*3.5 if plat.shake>0 else 0.0
	var sr : Rect2 = Rect2(r.position.x+sx, r.position.y, r.size.x, r.size.y)
	var bc : Color; var tc : Color
	match map_bg:
		0:  bc=Color(0.16,0.20,0.44); tc=Color(0.32,0.38,0.78)
		1:  bc=Color(0.26,0.46,0.16); tc=Color(0.42,0.70,0.25)
		2:  bc=Color(0.38,0.16,0.06); tc=Color(0.62,0.26,0.10)
		3:  bc=Color(0.20,0.14,0.30); tc=Color(0.36,0.24,0.52)
		4:  bc=Color(0.06,0.04,0.20); tc=Color(0.22,0.08,0.54)
		5:  bc=Color(0.44,0.20,0.06); tc=Color(0.68,0.36,0.10)
		6:  bc=Color(0.06,0.26,0.46); tc=Color(0.12,0.40,0.65)
		7:  bc=Color(0.18,0.38,0.10); tc=Color(0.30,0.58,0.16)
		8:  bc=Color(0.20,0.20,0.30); tc=Color(0.36,0.36,0.52)
		9:  bc=Color(0.48,0.52,0.62); tc=Color(0.65,0.70,0.82)
		10: bc=Color(0.68,0.54,0.28); tc=Color(0.86,0.72,0.40)
		_:  bc=Color(0.20,0.22,0.38); tc=Color(0.38,0.40,0.62)
	if plat.marked:
		var d : float = abs(sin(anim_time*11.0))
		bc = bc.lerp(Color(0.85,0.15,0.05), d*0.78)
		tc = tc.lerp(Color(1.0,0.38,0.12), d*0.78)
	c.draw_rect(Rect2(sr.position.x+2,sr.position.y+2,sr.size.x,sr.size.y), Color(0,0,0,0.36))
	c.draw_rect(sr, bc)
	c.draw_rect(Rect2(sr.position.x,sr.position.y,sr.size.x,sr.size.y*0.22), Color(1,1,1,0.07))
	c.draw_line(Vector2(sr.position.x,sr.position.y),
				Vector2(sr.position.x+sr.size.x,sr.position.y), tc, 2.8)


func draw_lava(c: Node2D, lava_y: float, lava_wave: float) -> void:
	if Globals.VH - lava_y <= 0: return

	var glow_h : float = 14.0
	c.draw_rect(Rect2(0, lava_y - glow_h, Globals.VW, glow_h), Color(1,0.42,0.05,0.22))
	c.draw_rect(Rect2(0, lava_y, Globals.VW, Globals.VH - lava_y), Color(0.88,0.26,0.0))

	var segs : Array = Mapgen.marching_squares_lava(lava_y, lava_wave)
	for seg in segs:
		c.draw_line(seg.a, seg.b, Color(1.0, 0.82, 0.22, 0.9), 2.0)

	for i in 6:
		var bx : float = fmod(lava_wave * 28.0 + float(i)*82.0, Globals.VW)
		var by : float = lava_y - 2.5 + sin(lava_wave*1.5 + float(i))*2.0
		c.draw_circle(Vector2(bx, by), 2.8, Color(1,0.72,0.18,0.7))

func draw_king_zone(c: Node2D, king_rect: Rect2, p1_in: bool, p2_in: bool, kt: Array) -> void:
	var zcol : Color = Color(1,1,0,0.12)
	if p1_in and not p2_in: zcol=Color(Globals.C_P1.r,Globals.C_P1.g,Globals.C_P1.b,0.28)
	elif p2_in and not p1_in: zcol=Color(Globals.C_P2.r,Globals.C_P2.g,Globals.C_P2.b,0.28)
	c.draw_rect(king_rect, zcol)
	c.draw_rect(king_rect, Color(1,1,0,0.35+abs(sin(time*3.2))*0.38), false, 1.8)
	var cx : float = king_rect.position.x + king_rect.size.x/2.0
	var cy : float = king_rect.position.y + king_rect.size.y/2.0
	c.draw_string(ThemeDB.fallback_font, Vector2(cx, cy+5),
				  "♛", HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color(1,0.9,0.2,0.52))
	var by_ : float = king_rect.position.y - 14
	c.draw_string(ThemeDB.fallback_font, Vector2(king_rect.position.x+2, by_),
				  "%.1f" % float(kt[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Globals.C_P1)
	c.draw_string(ThemeDB.fallback_font, Vector2(king_rect.position.x+king_rect.size.x-2, by_),
				  "%.1f" % float(kt[1]), HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Globals.C_P2)
