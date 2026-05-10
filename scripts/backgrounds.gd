extends Node

var time  : float = 0.0
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
		_: pass 

func _draw_cloud(c: Node2D, x: float, y: float, w: float, a: float):
	var col := Color(1,1,1,a)
	c.draw_circle(Vector2(x,y), w*0.3, col)
	c.draw_circle(Vector2(x+w*0.22,y-w*0.12), w*0.22, col)
	c.draw_circle(Vector2(x-w*0.18,y-w*0.1), w*0.2, col)
	c.draw_circle(Vector2(x+w*0.40,y), w*0.17, col)
