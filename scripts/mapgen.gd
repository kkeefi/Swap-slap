extends Node

const VW := 480.0
const VH := 270.0

const JUMP_H := 52.0
const JUMP_DIST := 130.0
const P_HALF_W := 7.0
const P_HALF_H := 10.0

const PLAT_MIN_W := 45.0
const PLAT_MAX_W := 130.0
const PLAT_H := 12.0

func generate(mode: int) -> Dictionary:
	var bg: int = randi() % 11

	match mode:
		Globals.Mode.BATTLE_RING: return _gen_battle(bg)
		Globals.Mode.CRUMBLING: return _gen_crumble(bg)
	return _gen_battle(bg)
	
func _gen_battle(bg: int) -> Dictionary:
	var attempt: int = 0
	while attempt < 20:
		attempt += 1
		var plats: Array = _bsp_generate(6, 8, 140.0, 220.0)
		if plats.is_empty(): continue

		var floor_w: float = randf_range(200.0, 320.0)
		var floor_plat: Dictionary = _make_plat(VW/2.0, 228.0, floor_w)
		plats.push_front(floor_plat)

		var p1_pos: Vector2 = _find_spawn_on(plats, VW*0.25)
		var p2_pos: Vector2 = _find_spawn_on(plats, VW*0.75)
		if p1_pos == Vector2.ZERO or p2_pos == Vector2.ZERO: continue
		if not _validate_reachability(plats, p1_pos, p2_pos): continue

		return {"bg":bg,"plats":_plats_to_array(plats),"p1":[p1_pos.x,p1_pos.y],"p2":[p2_pos.x,p2_pos.y]}

	return _fallback_battle(bg)
	
func _gen_crumble(bg: int) -> Dictionary:
	var tile_w: float = randf_range(18.0, 42.0)
	var tile_gap: float = randf_range(2.0, 6.0)
	var tile_y: float = randf_range(210.0, 222.0)
	var count: int = int((VW - 80.0) / (tile_w + tile_gap))
	count = clamp(count, 5, 18)
	var total_w: float = count * (tile_w + tile_gap) - tile_gap
	var start_x: float = (VW - total_w) / 2.0

	var plats: Array = []
	for i in range(count):
		var cx: float = start_x + i*(tile_w+tile_gap) + tile_w/2.0
		plats.append(_make_plat(cx, tile_y, tile_w))

	var upper: Array = _wave_upper_platforms(2, 4, 145.0, 185.0, plats)
	for p in upper: plats.append(p)

	var p1_pos: Vector2 = _find_spawn_on(plats, VW*0.25)
	var p2_pos: Vector2 = _find_spawn_on(plats, VW*0.75)
	if p1_pos == Vector2.ZERO: p1_pos = Vector2(start_x + tile_w/2.0, tile_y - P_HALF_H*2 - 2)
	if p2_pos == Vector2.ZERO: p2_pos = Vector2(start_x + total_w - tile_w/2.0, tile_y - P_HALF_H*2 - 2)

	return {"bg":bg,"crumble_tiles":_plats_to_array(plats),"p1":[p1_pos.x,p1_pos.y],"p2":[p2_pos.x,p2_pos.y]}

func _bsp_generate(min_plats: int, max_plats: int, y_min: float, y_max: float) -> Array:
	var target: int = int(randf_range(min_plats, max_plats + 1))

	var zones: Array = []
	zones.append({"x0":55.0,"x1":VW-55.0,"y0":y_min,"y1":y_max})

	var iter: int = 0
	while zones.size() < target and iter < 30:
		iter += 1
		var widest_idx: int = 0
		var widest_w: float = 0.0
		for i in range(zones.size()):
			var w: float = zones[i].x1 - zones[i].x0
			if w > widest_w: widest_w = w; widest_idx = i

		var z: Dictionary = zones[widest_idx]
		if z.x1 - z.x0 < 90.0: break

		var split: float = randf_range(z.x0 + 45.0, z.x1 - 45.0)
		var left: Dictionary = {"x0":z.x0,"x1":split,"y0":z.y0,"y1":z.y1}
		var right: Dictionary = {"x0":split,"x1":z.x1,"y0":z.y0,"y1":z.y1}

		var y_shift: float = randf_range(-20.0, 20.0)
		right.y0 = clamp(z.y0 + y_shift, y_min, y_max - 15)
		right.y1 = clamp(z.y1 + y_shift * 0.5, y_min + 15, y_max)

		zones.remove_at(widest_idx)
		zones.append(left)
		zones.append(right)

	var plats: Array = []
	for zone in zones:
		var cx: float = randf_range(zone.x0 + PLAT_MIN_W/2.0, zone.x1 - PLAT_MIN_W/2.0)
		var cy: float = randf_range(zone.y0, zone.y1)
		var w: float = randf_range(PLAT_MIN_W, min(PLAT_MAX_W, zone.x1 - zone.x0 - 10))
		plats.append({"x":cx,"y":cy,"w":w})

	return plats
	
func _wave_upper_platforms(min_c: int, max_c: int, y_min: float, y_max: float, existing: Array) -> Array:
	var count: int = int(randf_range(min_c, max_c + 1))
	var result: Array = []

	var occupied: Array = []
	for p in existing:
		occupied.append({"x0":p.x - p.w/2.0, "x1":p.x + p.w/2.0})

	var spacing: float = (VW - 80.0) / (count + 1)
	for i in range(count):
		var x: float = 40.0 + (i + 1) * spacing + randf_range(-25.0, 25.0)
		var y: float = randf_range(y_min, y_max)
		var w: float = randf_range(PLAT_MIN_W, 90.0)

		for occ in occupied:
			if x + w/2.0 > occ.x0 and x - w/2.0 < occ.x1:
				y = y_min + randf() * (y_max - y_min)

		result.append({"x":x,"y":y,"w":w})
		occupied.append({"x0":x - w/2.0, "x1":x + w/2.0})

	return result

func _validate_reachability(plats: Array, from_pos: Vector2, to_pos: Vector2) -> bool:
	var n: int = plats.size()
	if n == 0: return false

	var start_plat: int = _plat_below(plats, from_pos)
	var end_plat: int   = _plat_below(plats, to_pos)
	if start_plat < 0 or end_plat < 0: return false
	if start_plat == end_plat: return true

	var visited: Dictionary = {}
	var queue: Array = [start_plat]
	visited[start_plat] = true

	while not queue.is_empty():
		var cur: int = queue.pop_front()
		if cur == end_plat: return true

		var cp: Dictionary = plats[cur]
		var cx: float = cp.x if "x" in cp else cp.rect.get_center().x
		var cy: float = cp.y if "y" in cp else cp.rect.position.y

		for j in range(n):
			if visited.has(j): continue
			var tp: Dictionary = plats[j]
			var tx: float = tp.x if "x" in tp else tp.rect.get_center().x
			var ty: float = tp.y if "y" in tp else tp.rect.position.y

			if _can_jump(cx, cy, tx, ty):
				visited[j] = true
				queue.append(j)

	return false

func _can_jump(x1: float, y1: float, x2: float, y2: float) -> bool:
	var dx: float = abs(x2 - x1)
	var dy: float = y1 - y2
	if dx > JUMP_DIST + 20: return false
	if dy > JUMP_H + 5: return false
	if dy < -JUMP_H * 1.5: return false
	return true
	
func _plat_below(plats: Array, pos: Vector2) -> int:
	var best: int = -1
	var best_y: float = 9999.0
	for i in range(plats.size()):
		var p: Dictionary = plats[i]
		var px: float = p.x if "x" in p else p.rect.get_center().x
		var py: float = p.y if "y" in p else p.rect.position.y
		var pw: float = p.w if "w" in p else p.rect.size.x
		if pos.x >= px - pw/2.0 and pos.x <= px + pw/2.0 and py >= pos.y and py < best_y:
			best = i
			best_y = py
	return best

func _make_plat(cx: float, cy: float, w: float) -> Dictionary:
	return {"x":cx, "y":cy, "w":clamp(w, PLAT_MIN_W, PLAT_MAX_W)}

func _plats_to_array(plats: Array) -> Array:
	var result: Array = []
	for p in plats:
		if "rect" in p:
			var r: Rect2 = p.rect
			result.append([r.get_center().x, r.get_center().y, r.size.x, r.size.y])
		else:
			result.append([p.x, p.y, p.w, PLAT_H])
	return result

func _find_spawn_on(plats: Array, preferred_x: float) -> Vector2:
	var best: Dictionary = {}
	var best_d: float = 9999.0
	for p in plats:
		var px: float = p.x if "x" in p else p.rect.get_center().x
		var py: float = p.y if "y" in p else p.rect.position.y
		var d: float = abs(px - preferred_x)
		if d < best_d: best_d = d; best = p
	if best.is_empty(): return Vector2.ZERO
	var bx: float = best.x if "x" in best else best.rect.get_center().x
	var by: float = best.y if "y" in best else best.rect.position.y
	return Vector2(bx, by - PLAT_H/2.0 - P_HALF_H - 2)
	
func _fallback_battle(bg: int) -> Dictionary:
	return {"bg":bg,"p1":[155,200],"p2":[325,200],
			"plats":[[240,228,300,14],[130,185,78,10],[350,185,78,10]]}
