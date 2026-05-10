extends Node

var time : float = 0.0
var stars : Array = []
var clouds: Array = []

func init():
	_gen_stars()
	_gen_clouds()

func _gen_stars():
	stars.clear()
	for i in 65:
		stars.append({"pos":Vector2(randf()*Globals.VW, randf()*Globals.VH),
			"bright":randf_range(0.08,0.6),"size":randf_range(0.5,2.0),"tw":randf()*TAU})

func _gen_clouds():
	clouds.clear()
	for i in 7:
		clouds.append({"x":randf()*Globals.VW,"y":randf_range(18.0,95.0),
			"w":randf_range(38.0,90.0),"spd":randf_range(4.0,14.0),"a":randf_range(0.38,0.82)})

func update(delta: float):
	time += delta
	for c in clouds:
		c.x += c.spd * delta
		if c.x > Globals.VW + 65: c.x = -95.0

func draw(canvas: Node2D, bg_id: int):
	match bg_id:
		0: _bg_space(canvas)
		1: _bg_sky(canvas)
		2: _bg_volcano(canvas)
		3: _bg_cave(canvas)
		4: _bg_neon(canvas)
		5: _bg_sunset(canvas)
		_: _bg_space(canvas)

func _draw_cloud(c: Node2D, x: float, y: float, w: float, a: float):
	var col := Color(1,1,1,a)
	c.draw_circle(Vector2(x,y), w*0.3, col)
	c.draw_circle(Vector2(x+w*0.22,y-w*0.12), w*0.22, col)
	c.draw_circle(Vector2(x-w*0.18,y-w*0.1), w*0.2, col)
	c.draw_circle(Vector2(x+w*0.40,y), w*0.17, col)
	
func _bg_space(c: Node2D):
	c.draw_rect(Rect2(0,0,Globals.VW,Globals.VH), Color(0.02,0.02,0.06))
	for s in stars:
		var b: float = s.bright + sin(time*1.3+s.tw)*0.09
		c.draw_circle(s.pos, s.size, Color(b,b,b+0.1,b))
	c.draw_circle(Vector2(385,55), 28, Color(0.22,0.48,0.88,0.9))
	c.draw_circle(Vector2(380,50), 28, Color(0.18,0.38,0.75,0.4))
	c.draw_line(Vector2(352,70),Vector2(420,40),Color(0.5,0.72,1.0,0.38),5.0)
	c.draw_circle(Vector2(88,148), 18, Color(0.78,0.55,0.32,0.85))
	c.draw_circle(Vector2(88,148), 24, Color(0.78,0.55,0.32,0.2))
	c.draw_circle(Vector2(385,55), 48, Color(0.22,0.48,0.88,0.08))
	
func _bg_sky(c: Node2D):
	for y in range(0,int(Globals.VH),4):
		var t: float = float(y)/Globals.VH
		c.draw_rect(Rect2(0,y,Globals.VW,4), Color(0.48+t*0.12,0.72+t*0.08,0.98-t*0.1))
	for cl in clouds: _draw_cloud(c, cl.x, cl.y, cl.w, cl.a)
	for i in 4:
		var bx: float = fmod(time*22.0*(0.8+i*0.15)+i*112.0, Globals.VW+65)-32
		var by: float = 52.0+i*14.0+sin(time+i)*4.0
		c.draw_line(Vector2(bx-8,by),Vector2(bx,by-4),Color(0.1,0.1,0.15,0.6),1.5)
		c.draw_line(Vector2(bx,by-4),Vector2(bx+8,by),Color(0.1,0.1,0.15,0.6),1.5)

func _bg_volcano(c: Node2D):
	c.draw_rect(Rect2(0,0,Globals.VW,Globals.VH), Color(0.1,0.04,0.02))
	for y in range(0,int(Globals.VH*0.5),3):
		var t: float = float(y)/(Globals.VH*0.5)
		c.draw_rect(Rect2(0,y,Globals.VW,3), Color(0.22+t*0.08,0.06+t*0.04,0.02))
	
	var volcano_colors = PackedColorArray([Color(0.18,0.08,0.04), Color(0.18,0.08,0.04), Color(0.18,0.08,0.04)])
	c.draw_polygon(PackedVector2Array([Vector2(240,15),Vector2(75,Globals.VH*0.6),Vector2(405,Globals.VH*0.6)]), volcano_colors)
	
	var lava_colors = PackedColorArray([Color(0.9,0.22,0.05,0.85), Color(0.9,0.22,0.05,0.85), Color(0.9,0.22,0.05,0.85)])
	c.draw_polygon(PackedVector2Array([Vector2(240,15),Vector2(200,46),Vector2(280,46)]), lava_colors)
	
	for i in 4:
		c.draw_line(Vector2(222+i*6,46),Vector2(226+i*25,Globals.VH*0.6),Color(0.95,0.42,0.05,0.68),2.5)
	for i in 20:
		var sx: float = fmod(time*22.0+i*23.0,80.0)-40+240
		var sy: float = fmod(time*16.0+i*15.0,60.0)+12
		c.draw_circle(Vector2(sx,sy), 1.5+i%3, Color(1,0.7,0.12,0.88))
		
func _bg_cave(c: Node2D):
	c.draw_rect(Rect2(0,0,Globals.VW,Globals.VH), Color(0.05,0.04,0.08))
	
	for i in 15:
		var sx: float = 15.0+i*33.0
		var star_bright: float = stars[i%stars.size()].bright if not stars.is_empty() else 0.3
		var sh: float = 14.0 + star_bright * 48.0
		var stal_colors = PackedColorArray([Color(0.2,0.14,0.26), Color(0.2,0.14,0.26), Color(0.2,0.14,0.26)])
		c.draw_polygon(PackedVector2Array([Vector2(sx-7,0),Vector2(sx+7,0),Vector2(sx,sh)]), stal_colors)
	
	for i in 10:
		var sx: float = 25.0+i*46.0
		var star_bright: float = stars[(i+4)%stars.size()].bright if not stars.is_empty() else 0.2
		var sh: float = 11.0 + star_bright * 34.0
		var stal_colors2 = PackedColorArray([Color(0.18,0.12,0.24), Color(0.18,0.12,0.24), Color(0.18,0.12,0.24)])
		c.draw_polygon(PackedVector2Array([Vector2(sx-5,Globals.VH),Vector2(sx+5,Globals.VH),Vector2(sx,Globals.VH-sh)]), stal_colors2)
	
	for i in 5:
		var cx: float = 55.0+i*74.0
		var cy: float = Globals.VH-40.0
		var gem_colors = PackedColorArray([Color(0.38,0.16,0.78,0.75), Color(0.38,0.16,0.78,0.75), Color(0.38,0.16,0.78,0.75)])
		c.draw_polygon(PackedVector2Array([Vector2(cx,cy-19),Vector2(cx-5,cy),Vector2(cx+5,cy)]), gem_colors)
	
	for i in 8:
		var dx: float = 38.0+i*52.0
		var dy: float = fmod(time*28.0+i*38.0, Globals.VH*0.5)
		c.draw_circle(Vector2(dx,dy), 2.0, Color(0.4,0.62,1.0,0.65))
		
func _bg_neon(c: Node2D):
	c.draw_rect(Rect2(0,0,Globals.VW,Globals.VH), Color(0.02,0.02,0.05))
	for x in range(0,int(Globals.VW),42): c.draw_line(Vector2(x,0),Vector2(x,Globals.VH),Color(0.1,0.05,0.25,0.55),0.5)
	for y in range(0,int(Globals.VH),42): c.draw_line(Vector2(0,y),Vector2(Globals.VW,y),Color(0.1,0.05,0.25,0.55),0.5)
	var ncols := [Color(1,0.08,0.8),Color(0.08,1,0.82),Color(0.08,0.5,1),Color(1,0.85,0.08)]
	for i in 6:
		var bx: float = 16.0+i*76.0
		var nc: Color = ncols[i%4]
		c.draw_rect(Rect2(bx,Globals.VH*0.14,56,Globals.VH*0.54),Color(0.06,0.06,0.10))
		c.draw_rect(Rect2(bx,Globals.VH*0.14,56,Globals.VH*0.54),Color(nc.r,nc.g,nc.b,0.12),false,1.5)
		for j in 4: c.draw_rect(Rect2(bx+5,Globals.VH*0.22+j*22,46,3),Color(nc.r,nc.g,nc.b,0.58))
	c.draw_circle(Vector2(Globals.VW*0.5, Globals.VH*0.78), 35, Color(1,0.08,0.8,0.08))
	
func _bg_sunset(c: Node2D):
	for y in range(0,int(Globals.VH),3):
		var t: float = float(y)/Globals.VH
		c.draw_rect(Rect2(0,y,Globals.VW,3), Color(0.9-t*0.32,0.42+t*0.18,0.12+t*0.28))
	c.draw_circle(Vector2(240,Globals.VH*0.54), 36, Color(1,0.85,0.28,0.92))
	c.draw_circle(Vector2(240,Globals.VH*0.54), 54, Color(1,0.72,0.18,0.25))
	for cl in clouds: _draw_cloud(c, cl.x, cl.y, cl.w, cl.a*0.68)
	
	var hill_colors = PackedColorArray([Color(0.12,0.08,0.06), Color(0.12,0.08,0.06), Color(0.12,0.08,0.06), Color(0.12,0.08,0.06), Color(0.12,0.08,0.06), Color(0.12,0.08,0.06)])
	c.draw_polygon(PackedVector2Array([Vector2(0,Globals.VH),Vector2(0,Globals.VH*0.7),Vector2(120,Globals.VH*0.55),Vector2(240,Globals.VH*0.7),Vector2(Globals.VW,Globals.VH*0.62),Vector2(Globals.VW,Globals.VH)]), hill_colors)
