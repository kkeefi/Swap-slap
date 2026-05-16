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
			
var _hit_flash : float = 0.0
var _death_flash : float = 0.0
var _death_col : Color = Color(1,0,0)
var _sparks : Array = []

func on_hit() -> void:
	_hit_flash=0.22

func on_death(col:Color) -> void:
	_death_flash=0.32; _death_col=col
	for i in 16:
		var a:float=randf()*TAU; var s:float=randf_range(40.0,130.0)
		_sparks.append({"pos":Vector2(randf()*Globals.VW,randf()*Globals.VH),"vel":Vector2(cos(a)*s,sin(a)*s),"life":randf_range(0.4,0.9),"col":col})

func update(delta: float):
	time += delta
	if _hit_flash>0: _hit_flash  =max(0.0,_hit_flash-delta*6.0)
	if _death_flash>0: _death_flash=max(0.0,_death_flash-delta*4.0)
	for i in range(_sparks.size()-1,-1,-1):
		var sp:Dictionary=_sparks[i]; sp.life-=delta
		sp.pos+=sp.vel*delta; sp.vel.y+=200.0*delta
		if sp.life<=0: _sparks.remove_at(i)
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
		6: _bg_underwater(canvas)
		7: _bg_forest(canvas)
		8: _bg_storm(canvas)
		9: _bg_tundra(canvas)
		10: _bg_desert(canvas)
		_: _bg_space(canvas)
	_draw_events(canvas)
	
func _draw_events(c:Node2D) -> void:
	if _hit_flash>0: c.draw_rect(Rect2(0,0,Globals.VW,Globals.VH),Color(1,0.9,0.3,_hit_flash*0.3))
	if _death_flash>0: c.draw_rect(Rect2(0,0,Globals.VW,Globals.VH),Color(_death_col.r,_death_col.g,_death_col.b,_death_flash*0.25))
	for sp in _sparks:
		var a:float=clamp(sp.life*3.0,0.0,1.0)
		c.draw_circle(sp.pos,3.5*a,Color(sp.col.r,sp.col.g,sp.col.b,a))
	if Globals.dj_mode:
		var pulse:float=abs(sin(time*TAU*2.14))*0.10
		c.draw_rect(Rect2(0,0,Globals.VW,Globals.VH),Color(0.5,0.1,0.9,pulse))

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

func _bg_underwater(c: Node2D):
	for y in range(0,int(Globals.VH),3):
		var t: float = float(y)/Globals.VH
		c.draw_rect(Rect2(0,y,Globals.VW,3), Color(0.02+t*0.05,0.18+t*0.12,0.48+t*0.18))
	for i in 5:
		var bx: float = 58.0+i*90.0
		c.draw_line(Vector2(bx,0),Vector2(bx+26+sin(time+i)*16,Globals.VH),Color(0.6,0.85,1.0,0.07),24.0)
	for i in 20:
		var bub_x: float = 22.0+i*24.0
		var bub_y: float = fmod(time*18.0*(0.8+i%3*0.2)+i*28.0, Globals.VH)
		c.draw_circle(Vector2(bub_x,Globals.VH-bub_y), 2.5+i%4, Color(0.7,0.9,1.0,0.48))
	for i in 9:
		var cx: float = 28.0+i*52.0
		for b in 3:
			c.draw_line(Vector2(cx+b*8-8,Globals.VH),Vector2(cx+b*8-8+sin(b)*5,Globals.VH-28-b*16),Color(0.9,0.25+b*0.15,0.35+b*0.1,0.88),3.0)
	for i in 5:
		var fx: float = fmod(time*22.0+i*88.0,Globals.VW+22)-12
		var fy: float = 55.0+i*28.0+sin(time+i*1.4)*12.0
		var fish_colors = PackedColorArray([Color(1,0.6,0.2), Color(1,0.6,0.2), Color(1,0.6,0.2)])
		c.draw_polygon(PackedVector2Array([Vector2(fx,fy),Vector2(fx-10,fy-4),Vector2(fx-10,fy+4)]), fish_colors)
		c.draw_circle(Vector2(fx+2,fy), 5, Color(1,0.6,0.2,0.9))

func _bg_forest(c: Node2D):
	for y in range(0,int(Globals.VH*0.5),3):
		var t: float = float(y)/(Globals.VH*0.5)
		c.draw_rect(Rect2(0,y,Globals.VW,3), Color(0.55+t*0.05,0.82+t*0.04,0.98-t*0.2,0.6))
	c.draw_rect(Rect2(0,0,Globals.VW,Globals.VH), Color(0.1,0.22,0.08,0.5))
	for i in 12:
		var tx: float = i*42.0+8
		var th: float = 85.0+i%4*22.0
		c.draw_rect(Rect2(tx-4,Globals.VH-th,8,th), Color(0.22,0.16,0.08))
		c.draw_circle(Vector2(tx,Globals.VH-th), 26+i%4*8, Color(0.18,0.48,0.1,0.9))
		c.draw_circle(Vector2(tx-10,Globals.VH-th+10), 18, Color(0.24,0.55,0.12,0.78))
		c.draw_circle(Vector2(tx+10,Globals.VH-th+8), 20, Color(0.15,0.45,0.08,0.78))
	for i in 8:
		var lx: float = 32.0+i*56.0
		c.draw_line(Vector2(lx,0),Vector2(lx+sin(time*0.5+i)*12,Globals.VH*0.58),Color(0.28,0.52,0.12,0.62),2.0)
	for i in 14:
		var fx: float = 18.0+i*34.0
		var fy: float = Globals.VH*0.6+sin(i*1.3)*14.0
		c.draw_circle(Vector2(fx,fy), 4.5, Color(1,0.38,0.62,0.92))
		c.draw_circle(Vector2(fx,fy), 2.0, Color(1,0.92,0.2))
		
func _bg_storm(c: Node2D):
	for y in range(0,int(Globals.VH),4):
		var t: float = float(y)/Globals.VH
		c.draw_rect(Rect2(0,y,Globals.VW,4), Color(0.1+t*0.06,0.12+t*0.08,0.2+t*0.06))
	for cl in clouds:
		_draw_cloud(c, cl.x, cl.y, cl.w*1.35, cl.a*0.78)
		_draw_cloud(c, cl.x+22, cl.y+12, cl.w, cl.a*0.62)
	for i in 3:
		if sin(time*5.0+i*2.1)>0.85:
			var lx: float = 78.0+i*148.0
			c.draw_line(Vector2(lx,0),Vector2(lx+14,52),Color(0.92,0.92,1.0,0.92),2.0)
			c.draw_line(Vector2(lx+14,52),Vector2(lx-4,102),Color(0.92,0.92,1.0,0.92),2.0)
			c.draw_line(Vector2(lx-4,102),Vector2(lx+12,152),Color(0.92,0.92,1.0,0.92),2.0)
			c.draw_circle(Vector2(lx,0), 8, Color(1,1,0.8,0.42))
	for i in 32:
		var rx: float = fmod(time*82.0+i*17.0, Globals.VW)
		var ry: float = fmod(time*124.0+i*22.0, Globals.VH)
		c.draw_line(Vector2(rx,ry),Vector2(rx-3,ry+12),Color(0.5,0.65,0.95,0.58),1.0)
		
func _bg_tundra(c: Node2D):
	for y in range(0,int(Globals.VH),3):
		var t: float = float(y)/Globals.VH
		c.draw_rect(Rect2(0,y,Globals.VW,3), Color(0.62+t*0.1,0.72+t*0.08,0.88+t*0.04))
	var mtns = [[0,142,165],[118,98,138],[248,115,148],[385,92,128],[445,132,85]]
	for m in mtns:
		var mtn_colors = PackedColorArray([Color(0.75,0.8,0.92), Color(0.75,0.8,0.92), Color(0.75,0.8,0.92)])
		c.draw_polygon(PackedVector2Array([Vector2(m[0],m[1]),Vector2(m[0]-m[2]*0.6,Globals.VH*0.58),Vector2(m[0]+m[2]*0.6,Globals.VH*0.58)]), mtn_colors)
		var snow_colors = PackedColorArray([Color(0.95,0.97,1.0), Color(0.95,0.97,1.0), Color(0.95,0.97,1.0)])
		c.draw_polygon(PackedVector2Array([Vector2(m[0],m[1]),Vector2(m[0]-m[2]*0.22,m[1]+m[2]*0.3),Vector2(m[0]+m[2]*0.22,m[1]+m[2]*0.3)]), snow_colors)
	for i in 28:
		var sx: float = fmod(time*6.5+i*20.0+sin(time+i)*8.0, Globals.VW)
		var sy: float = fmod(time*10.5+i*14.0, Globals.VH)
		c.draw_circle(Vector2(sx,sy), 1.5+i%3*0.5, Color(1,1,1,0.68))

func _bg_desert(c: Node2D):
	for y in range(0,int(Globals.VH*0.58),3):
		var t: float = float(y)/(Globals.VH*0.58)
		c.draw_rect(Rect2(0,y,Globals.VW,3), Color(0.98-t*0.1,0.72-t*0.15,0.22+t*0.05))
	c.draw_rect(Rect2(0,Globals.VH*0.58,Globals.VW,Globals.VH*0.42), Color(0.88,0.75,0.45))
	for i in 5:
		var dx: float = i*100.0
		var dh: float = Globals.VH*0.4+sin(i*0.8)*14
		var dune_colors = PackedColorArray([Color(0.88,0.75,0.45), Color(0.88,0.75,0.45), Color(0.88,0.75,0.45)])
		c.draw_polygon(PackedVector2Array([Vector2(dx,Globals.VH),Vector2(dx+100,Globals.VH),Vector2(dx+50,dh)]), dune_colors)
	for i in 4:
		var cx: float = 52.0+i*118.0
		var ch: float = 38.0+i%3*12.0
		c.draw_rect(Rect2(cx-5,Globals.VH*0.58-ch,10,ch),Color(0.24,0.54,0.16))
		c.draw_rect(Rect2(cx-17,Globals.VH*0.58-ch*0.65,12,5),Color(0.24,0.54,0.16))
		c.draw_rect(Rect2(cx+5,Globals.VH*0.58-ch*0.55,12,5),Color(0.24,0.54,0.16))
	c.draw_circle(Vector2(405,38), 22, Color(1,0.9,0.3,0.96))
	c.draw_circle(Vector2(405,38), 34, Color(1,0.9,0.3,0.26))
