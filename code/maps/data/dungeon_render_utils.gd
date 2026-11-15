class_name DungeonRenderUtils extends RefCounted

const DEPTH_WIDTHS: Array[int] = [3,  5,  7,  9]
const DEPTH_OFFSET: Array[int] = [-1, -2, -3, -4]


#region Default Perspective

const DEF_WALL_LUT: Dictionary = { # This is relative to the floor, meaning the height of the wall needs to be taken into account when drawing
	0: { "l": Vector2i(0, 14), "l1": Vector2i(0, 14), "f": Vector2i(8, 11), "r": Vector2i(24, 14), "r1": Vector2i(17, 9) },
	1: { "l": Vector2i(8, 11), "l1": Vector2i(8, 10), "f": Vector2i(12, 10), "r": Vector2i(20, 11), "r1": Vector2i(20, 10) },
	2: { "l": Vector2i(12, 10), "l1": Vector2i(8, 10), "f": Vector2i(14, 9), "r": Vector2i(18, 10), "r1": Vector2i(18, 10) },
	3: { "l": Vector2i(14, 9), "l1": Vector2i(14, 9), "f": Vector2i(10, 11), "r": Vector2i(17, 9), "r1": Vector2i(15, 9) }
}
const DEF_WALL_W_LUT: Array = [16, 8, 4, 2]


static func get_default_render_batch(pos: Vector2, facing: DungeonDirection.Facing, map: DungeonMapResource, reachable_positions: Array[Vector2i]) -> Array:
	var arr := []
	
	for d in range(3, -1, -1):
		arr.append_array(_gather_default_at_depth(pos, facing, d, map, reachable_positions))
	
	return arr


static func _gather_default_at_depth(pos: Vector2, facing: DungeonDirection.Facing, depth: int, map: DungeonMapResource, reachable_positions: Array[Vector2i]) -> Array:
	var buckets := {
		"l": [], "l1": [], "f": [], "r": [], "r1": []
	}
	var width := DEPTH_WIDTHS[depth]
	var offset_x := DEPTH_OFFSET[depth]
	
	for x in width + 1:
		var x_o := x + offset_x
		var sample_pos := _get_relative_frustrum(x_o, depth, Vector2i(roundi(pos.x), roundi(pos.y)), facing)
		
		if not reachable_positions.has(sample_pos):
			continue
		if map.is_valid_position(sample_pos):
			for f in 4:
				var relative_dir := DungeonDirection.get_relative(facing, f)
				if relative_dir == DungeonDirection.RelativeFacing.BEHIND:
					continue
				if depth == 3 and relative_dir == DungeonDirection.RelativeFacing.FLAT:
					continue
				if relative_dir == DungeonDirection.RelativeFacing.LEFT and x_o > 0:
					continue
				if relative_dir == DungeonDirection.RelativeFacing.RIGHT and x_o < 0:
					continue
				
				
				var edge := map.get_edge(sample_pos, f)
				var wall_w: int = DEF_WALL_W_LUT[depth]
				if edge == null:
					continue
				var rel_char := _relative_facing_to_char(relative_dir, x_o)
				if rel_char.contains("1"):
					if depth == 0: continue
					elif depth == 3: wall_w += 2
				
				var is_door := "d" if not rel_char.contains("1") and edge.type == DungeonEdgeResource.Type.DOOR and depth < 3 else ""
				var wall_id := "%s%s_d%d" % [is_door, rel_char, depth]
				buckets[rel_char].push_back([wall_id, DEF_WALL_LUT[depth][rel_char] + Vector2i((x_o) * wall_w, 0)])
	
	var to_return: Array = buckets['f']
	to_return.append_array(buckets['l1'])
	to_return.append_array(buckets['r1'])
	to_return.append_array(buckets['l'])
	to_return.append_array(buckets['r'])
	
	
	return to_return


static func _get_relative_frustrum(x: int, depth: int, position: Vector2i, facing: DungeonDirection.Facing) -> Vector2i:
	match facing:
		DungeonDirection.Facing.NORTH: return position + Vector2i( x, -depth)
		DungeonDirection.Facing.SOUTH: return position + Vector2i(-x,  depth)
		DungeonDirection.Facing.EAST:  return position + Vector2i( depth,  x)
		DungeonDirection.Facing.WEST:  return position + Vector2i(-depth, -x)
		_: return Vector2i()

#endregion
#region Turning Perspective

const TURN_WALL_ORDERING: Array[Vector2i] = [
	Vector2i(2, 2), Vector2i(1, 2), Vector2i(2, 1), 
	Vector2i(0, 2), Vector2i(1, 1), Vector2i(2, 0), 
	Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, 0)
]

const TURN_WALL_LUT := {
	# LEFT
	0: { 
		Vector2i(0, 0): ["tl_d0", Vector2i(-1, 13)], 
		Vector2i(0, 1): ["tl_d1", Vector2i(16, 11)], Vector2i(1, 0): ["tl1_d1", Vector2i(-1, 10)],
		Vector2i(0, 2): ["tl_d2", Vector2i(28, 10)], Vector2i(1, 1): ["tl1_d2", Vector2i(4, 10)],
		Vector2i(1, 2): ["tl_d3", Vector2i(16, 9)],
	},
	# RIGHT
	1: { 
		Vector2i(0, 0): ["tr_d0", Vector2i(16, 13)], 
		Vector2i(1, 0): ["tr_d1", Vector2i(4, 11)], Vector2i(0, 1): ["tr1_d1", Vector2i(28, 10)],
		Vector2i(2, 0): ["tr_d2", Vector2i(-2, 10)], Vector2i(1, 1): ["tr1_d2", Vector2i(16, 10)],
		Vector2i(2, 1): ["tr_d3", Vector2i(10, 9)],
	}
}

static func get_turning_render_batch(pos: Vector2, start_facing: DungeonDirection.Facing, target_facing: DungeonDirection.Facing, map: DungeonMapResource, reachable_positions: Array[Vector2i]) -> Array:
	var arr := []
	
	for i in TURN_WALL_ORDERING.size():
		var local_pos := TURN_WALL_ORDERING[i]
		var localized_local_pos := _localize_frustrum_turning(start_facing, target_facing, local_pos)
		var sample_pos := Vector2i(roundi(pos.x), roundi(pos.y)) + localized_local_pos
		
		if not reachable_positions.has(sample_pos):
			continue
		
		if map.is_valid_position(sample_pos):
			var edge1 := map.get_edge(sample_pos, start_facing)
			var edge2 := map.get_edge(sample_pos, target_facing)
			var draw_order := _draw_in_order(start_facing, target_facing, edge1, edge2)
			
			if draw_order[0] != null and TURN_WALL_LUT[0].has(local_pos):
				var item: Array = TURN_WALL_LUT[0][local_pos]
				var is_door := "d" if draw_order[0].type == DungeonEdgeResource.Type.DOOR else ""
				var tile_id := "%s%s" % [is_door, item[0]]
				arr.push_back([tile_id, item[1]])
			
			if draw_order[1] != null and TURN_WALL_LUT[1].has(local_pos):
				var item: Array = TURN_WALL_LUT[1][local_pos]
				var is_door := "d" if draw_order[1].type == DungeonEdgeResource.Type.DOOR else ""
				var tile_id := "%s%s" % [is_door, item[0]]
				arr.push_back([tile_id, item[1]])
	return arr


static func _localize_frustrum_turning(t1: DungeonDirection.Facing, t2: DungeonDirection.Facing, local_pos: Vector2i) -> Vector2i:
	if (t1 == DungeonDirection.Facing.NORTH and t2 == DungeonDirection.Facing.EAST) or (t1 == DungeonDirection.Facing.EAST and t2 == DungeonDirection.Facing.NORTH):
		return Vector2i(local_pos.y, -local_pos.x)
	elif (t1 == DungeonDirection.Facing.NORTH and t2 == DungeonDirection.Facing.WEST) or (t1 == DungeonDirection.Facing.WEST and t2 == DungeonDirection.Facing.NORTH):
		return Vector2i(-local_pos.x, -local_pos.y)
	elif (t1 == DungeonDirection.Facing.SOUTH and t2 == DungeonDirection.Facing.WEST) or (t1 == DungeonDirection.Facing.WEST and t2 == DungeonDirection.Facing.SOUTH):
		return Vector2i(-local_pos.y, local_pos.x)
	else: # South x EAST | EAST x South
		return Vector2i(local_pos.x, local_pos.y)


static func _draw_in_order(t1: DungeonDirection.Facing, t2: DungeonDirection.Facing, edge1: DungeonEdgeResource, edge2: DungeonEdgeResource) -> Array:
	if t1 == DungeonDirection.Facing.NORTH and t2 == DungeonDirection.Facing.EAST: return [edge1, edge2]
	elif t1 == DungeonDirection.Facing.EAST and t2 == DungeonDirection.Facing.NORTH: return [edge2, edge1]
	elif t1 == DungeonDirection.Facing.WEST and t2 == DungeonDirection.Facing.NORTH: return [edge1, edge2]
	elif t1 == DungeonDirection.Facing.NORTH and t2 == DungeonDirection.Facing.WEST: return [edge2, edge1]
	elif t1 == DungeonDirection.Facing.EAST and t2 == DungeonDirection.Facing.SOUTH: return [edge1, edge2]
	elif t1 == DungeonDirection.Facing.SOUTH and t2 == DungeonDirection.Facing.EAST: return [edge2, edge1]
	elif t1 == DungeonDirection.Facing.SOUTH and t2 == DungeonDirection.Facing.WEST: return [edge1, edge2]
	elif t1 == DungeonDirection.Facing.WEST and t2 == DungeonDirection.Facing.SOUTH: return [edge2, edge1]
	else: return [null, null]

#endregion
#region Step Perspective

const STEP_WALL_LUT: Dictionary = { # This is relative to the floor, meaning the height of the wall needs to be taken into account when drawing
	0: { "sl": Vector2i(0, 14), "sl1": Vector2i(0, 14), "sf": Vector2i(4, 13), "sr": Vector2i(28, 14), "sr1": Vector2i(17, 9) },
	1: { "sl": Vector2i(4, 13), "sl1": Vector2i(0, 14), "sf": Vector2i(10, 11), "sr": Vector2i(22, 13), "sr1": Vector2i(17, 9) },
	2: { "sl": Vector2i(10, 11), "sl1": Vector2i(6, 10), "sf": Vector2i(13, 10), "sr": Vector2i(19, 11), "sr1": Vector2i(19, 10) },
	3: { "sl": Vector2i(13, 10), "sl1": Vector2i(13, 10), "sf": Vector2i(13, 10), "sr": Vector2i(17, 10), "sr1": Vector2i(14, 10) },
}
const STEP_WALL_W_LUT: Array = [24, 12, 6, 4]


static func get_step_render_batch(pos: Vector2, facing: DungeonDirection.Facing, map: DungeonMapResource, reachable_positions: Array[Vector2i]) -> Array:
	var arr := []
	
	for d in range(3, -1, -1):
		arr.append_array(_gather_step_at_depth(pos, facing, d, map, reachable_positions))
	
	return arr


static func _gather_step_at_depth(pos: Vector2, facing: DungeonDirection.Facing, depth: int, map: DungeonMapResource, reachable_positions: Array[Vector2i]) -> Array:
	var buckets := {
		"sl": [], "sl1": [], "sf": [], "sr": [], "sr1": []
	}
	var width := DEPTH_WIDTHS[depth]
	var offset_x := DEPTH_OFFSET[depth]
	
	for x in width + 1:
		var x_o := x + offset_x
		var sample_pos := _get_relative_frustrum(x_o, depth, Vector2i(roundi(pos.x), roundi(pos.y)), facing)
		
		if not reachable_positions.has(sample_pos):
			continue
		
		if map.is_valid_position(sample_pos):
			for f in 4:
				var relative_dir := DungeonDirection.get_relative(facing, f)
				if relative_dir == DungeonDirection.RelativeFacing.BEHIND:
					continue
				if depth == 3 and relative_dir == DungeonDirection.RelativeFacing.FLAT:
					continue
				if relative_dir == DungeonDirection.RelativeFacing.LEFT and x_o > 0:
					continue
				if relative_dir == DungeonDirection.RelativeFacing.RIGHT and x_o < 0:
					continue
				
				
				var edge := map.get_edge(sample_pos, f)
				var wall_w: int = STEP_WALL_W_LUT[depth]
				if edge == null:
					continue
				var rel_char := "%s%s" % ["s", _relative_facing_to_char(relative_dir, x_o)]
				if rel_char.contains("1"):
					if depth < 2: continue
					elif depth == 3: wall_w += 2
				
				var is_door := "d" if not rel_char.contains("1") and edge.type == DungeonEdgeResource.Type.DOOR and depth < 3 else ""
				var wall_id := "%s%s_d%d" % [is_door, rel_char, depth]
				buckets[rel_char].push_back([wall_id, STEP_WALL_LUT[depth][rel_char] + Vector2i((x_o) * wall_w, 0)])
	
	var to_return: Array = buckets['sf']
	to_return.append_array(buckets['sl1'])
	to_return.append_array(buckets['sr1'])
	to_return.append_array(buckets['sl'])
	to_return.append_array(buckets['sr'])
	
	return to_return

#endregion


#region Helpers

static func _relative_facing_to_char(relative_facing: DungeonDirection.RelativeFacing, x: int) -> String:
	match relative_facing:
		DungeonDirection.RelativeFacing.LEFT: return "l" if x == 0 else "l1"
		DungeonDirection.RelativeFacing.FLAT: return "f"
		DungeonDirection.RelativeFacing.RIGHT: return "r" if x == 0 else "r1"
		_: return ""

#endregion
