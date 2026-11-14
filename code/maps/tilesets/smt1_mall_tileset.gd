extends LevelTileset

@export var tileset: BakeResultResource
var _current_offset := Vector2i(0, 0)
var _baked_walls := {}

func write_to_vram(vram, offset: Vector2i) -> void:
	_current_offset = offset
	vram.write_img(offset.x, offset.y, get_vram_data().get_image(), Rect2i(Vector2i(), get_vram_size()))

func get_vram_data() -> Texture2D: 
	return load(tileset.atlas_path)

func get_vram_size() -> Vector2i:
	return tileset.atlas_size

func get_complex_wall(key: String) -> Array:
	if _baked_walls.has(key):
		return _baked_walls[key]
	
	match key:
		"l_d0": _baked_walls[key] = _build_left_wall(0)
		"r_d0": _baked_walls[key] = _build_right_wall(0)
		"f_d0": _baked_walls[key] = _build_flat_wall(1)
		"l_d1": _baked_walls[key] = _build_left_wall(2)
		"r_d1": _baked_walls[key] = _build_right_wall(2)
		"f_d1": _baked_walls[key] = _build_flat_wall(3)
		"l_d2": _baked_walls[key] = _build_left_wall(4)
		"r_d2": _baked_walls[key] = _build_right_wall(4)
		"f_d2": _baked_walls[key] = _build_flat_wall(5)
		"l_d3": _baked_walls[key] = _build_left_wall(6)
		"r_d3": _baked_walls[key] = _build_right_wall(6)
		
		"dr_d0": _baked_walls[key] = _build_right_wall(7)
		"dl_d0": _baked_walls[key] = _build_left_wall(7)
		"dr_d1": _baked_walls[key] = _build_right_wall(8)
		"dl_d1": _baked_walls[key] = _build_left_wall(8)
		"dr_d2": _baked_walls[key] = _build_right_wall(9)
		"dl_d2": _baked_walls[key] = _build_left_wall(9)
		"dr_d3": _baked_walls[key] = _build_right_wall(10)
		"dl_d3": _baked_walls[key] = _build_left_wall(10)
	
	return _baked_walls[key]


# Works off the assumption that all sprites are by default drawn for right walls
func _build_left_wall(region: int) -> Array:
	if tileset == null:
		return []
	
	var region_cell_size: Vector2i = tileset.regions[region].size / tileset.tile_size
	
	var to_return = []
	for mapping in tileset.mappings:
		if mapping.region_index != region:
			continue
		if mapping.atlas_position == Vector2i(-1, -1):
			continue
		
		var x := region_cell_size.x - 1 - mapping.tile_position.x
		var y := mapping.tile_position.y
		
		to_return.push_back([
			_current_offset + (mapping.atlas_position / tileset.tile_size), 
			Vector2i(x, y), 
			true, 
			false, 
			mapping.has_transparency
		])
	
	return to_return


func _build_right_wall(region: int) -> Array:
	if tileset == null:
		return []
	
	var to_return = []
	for mapping in tileset.mappings:
		if mapping.region_index != region:
			continue
		if mapping.atlas_position == Vector2i(-1, -1):
			continue
		
		to_return.push_back([
			_current_offset + (mapping.atlas_position / tileset.tile_size), 
			mapping.tile_position, 
			false, 
			false, 
			mapping.has_transparency
		])
	
	return to_return


func _build_flat_wall(region: int) -> Array:
	if tileset == null:
		return []
	
	var region_cell_size: Vector2i = tileset.regions[region].size / tileset.tile_size
	
	var to_return = []
	for mapping in tileset.mappings:
		if mapping.region_index != region:
			continue
		if mapping.atlas_position == Vector2i(-1, -1):
			continue
		
		var rev_x := region_cell_size.x + region_cell_size.x - 1 - mapping.tile_position.x
		var rev_y := mapping.tile_position.y
		
		to_return.push_back([
			_current_offset + (mapping.atlas_position / tileset.tile_size), 
			mapping.tile_position, 
			false, 
			false, 
			mapping.has_transparency
		])
		
		to_return.push_back([
			_current_offset + (mapping.atlas_position / tileset.tile_size), 
			Vector2i(rev_x, rev_y), 
			true, 
			false, 
			mapping.has_transparency
		])
	
	return to_return


#region LEGACY

#var left_d3_wall = [
	#[Vector2i(5, 8), Vector2i(0, 0), true, false, true], 
	#[Vector2i(6, 8), Vector2i(0, 1), true, false, false], 
	#[Vector2i(7, 8), Vector2i(0, 2), true, false, true]
#]
#
#var right_d3_wall = [
	#[Vector2i(5, 8), Vector2i(0, 0), false, false, true], 
	#[Vector2i(6, 8), Vector2i(0, 1), false, false, false], 
	#[Vector2i(7, 8), Vector2i(0, 2), false, false, true]
#]
#
#var flat_d2_wall = [
	#[Vector2i(9, 11), Vector2i(0, 0), false, false, false], [Vector2i(10, 11), Vector2i(1, 0), false, false, false], 
	#[Vector2i(10, 11), Vector2i(2, 0), true, false, false], [Vector2i(9, 11), Vector2i(3, 0), true, false, false],  
	#[Vector2i(11, 11), Vector2i(0, 1), false, false, false], [Vector2i(12, 11), Vector2i(1, 1), false, false, false], 
	#[Vector2i(12, 11), Vector2i(2, 1), true, false, false], [Vector2i(11, 11), Vector2i(3, 1), true, false, false],  
	#[Vector2i(13, 11), Vector2i(0, 2), false, false, false], [Vector2i(14, 11), Vector2i(1, 2), false, false, false], 
	#[Vector2i(14, 11), Vector2i(2, 2), true, false, false], [Vector2i(13, 11), Vector2i(3, 2), true, false, false],  
#]
#
#var left_d2_wall = [
	#[Vector2i(10, 7), Vector2i(0, 0), true, false, true],
	#[Vector2i(11, 7), Vector2i(1, 1), true, false, true], [Vector2i(12, 7), Vector2i(0, 1), true, false, false],
	#[Vector2i(13, 7), Vector2i(1, 2), true, false, false], [Vector2i(14, 7), Vector2i(0, 2), true, false, false],
	#[Vector2i(15, 7), Vector2i(1, 3), true, false, false], [Vector2i(0, 8), Vector2i(0, 3), true, false, false],
	#[Vector2i(1, 8), Vector2i(1, 4), true, false, false], [Vector2i(2, 8), Vector2i(0, 4), true, false, false],
	#[Vector2i(3, 8), Vector2i(1, 5), true, false, true], [Vector2i(4, 8), Vector2i(0, 5), true, false, true],
#]
#
#var right_d2_wall = [
	#[Vector2i(10, 7), Vector2i(1, 0), false, false, true],
	#[Vector2i(11, 7), Vector2i(0, 1), false, false, true], [Vector2i(12, 7), Vector2i(1, 1), false, false, false],
	#[Vector2i(13, 7), Vector2i(0, 2), false, false, false], [Vector2i(14, 7), Vector2i(1, 2), false, false, false],
	#[Vector2i(15, 7), Vector2i(0, 3), false, false, false], [Vector2i(0, 8), Vector2i(1, 3), false, false, false],
	#[Vector2i(1, 8), Vector2i(0, 4), false, false, false], [Vector2i(2, 8), Vector2i(1, 4), false, false, false],
	#[Vector2i(3, 8), Vector2i(0, 5), false, false, true], [Vector2i(4, 8), Vector2i(1, 5), false, false, true],
#]
#
#var flat_d1_wall = [
	#[Vector2i(5, 10), Vector2i(0, 0), false, false, false], [Vector2i(6, 10), Vector2i(1, 0), false, false, false],
	#[Vector2i(7, 10), Vector2i(2, 0), false, false, false], [Vector2i(8, 10), Vector2i(3, 0), false, false, false],
	#[Vector2i(9, 10), Vector2i(0, 1), false, false, false], [Vector2i(10, 10), Vector2i(1, 1), false, false, false],
	#[Vector2i(11, 10), Vector2i(2, 1), false, false, false], [Vector2i(12, 10), Vector2i(3, 1), false, false, false],
	#[Vector2i(13, 10), Vector2i(0, 2), false, false, false], [Vector2i(14, 10), Vector2i(1, 2), false, false, false],
	#[Vector2i(15, 10), Vector2i(2, 2), false, false, false], [Vector2i(0, 11), Vector2i(3, 2), false, false, false],
	#[Vector2i(1, 11), Vector2i(0, 3), false, false, false], [Vector2i(2, 11), Vector2i(1, 3), false, false, false],
	#[Vector2i(3, 11), Vector2i(2, 3), false, false, false], [Vector2i(4, 11), Vector2i(3, 3), false, false, false],
	#[Vector2i(1, 11), Vector2i(0, 4), false, false, false], [Vector2i(2, 11), Vector2i(1, 4), false, false, false],
	#[Vector2i(3, 11), Vector2i(2, 4), false, false, false], [Vector2i(4, 11), Vector2i(3, 4), false, false, false],
	#[Vector2i(5, 11), Vector2i(0, 5), false, false, true], [Vector2i(6, 11), Vector2i(1, 5), false, false, true],
	#[Vector2i(7, 11), Vector2i(2, 5), false, false, true], [Vector2i(8, 11), Vector2i(3, 5), false, false, true],
	#
	#[Vector2i(5, 10), Vector2i(7, 0), true, false, false], [Vector2i(6, 10), Vector2i(6, 0), true, false, false],
	#[Vector2i(7, 10), Vector2i(5, 0), true, false, false], [Vector2i(8, 10), Vector2i(4, 0), true, false, false],
	#[Vector2i(9, 10), Vector2i(7, 1), true, false, false], [Vector2i(10, 10), Vector2i(6, 1), true, false, false],
	#[Vector2i(11, 10), Vector2i(5, 1), true, false, false], [Vector2i(12, 10), Vector2i(4, 1), true, false, false],
	#[Vector2i(13, 10), Vector2i(7, 2), true, false, false], [Vector2i(14, 10), Vector2i(6, 2), true, false, false],
	#[Vector2i(15, 10), Vector2i(5, 2), true, false, false], [Vector2i(0, 11), Vector2i(4, 2), true, false, false],
	#[Vector2i(1, 11), Vector2i(7, 3), true, false, false], [Vector2i(2, 11), Vector2i(6, 3), true, false, false],
	#[Vector2i(3, 11), Vector2i(5, 3), true, false, false], [Vector2i(4, 11), Vector2i(4, 3), true, false, false],
	#[Vector2i(1, 11), Vector2i(7, 4), true, false, false], [Vector2i(2, 11), Vector2i(6, 4), true, false, false],
	#[Vector2i(3, 11), Vector2i(5, 4), true, false, false], [Vector2i(4, 11), Vector2i(4, 4), true, false, false],
	#[Vector2i(5, 11), Vector2i(7, 5), true, false, true], [Vector2i(6, 11), Vector2i(6, 5), true, false, true],
	#[Vector2i(7, 11), Vector2i(5, 5), true, false, true], [Vector2i(8, 11), Vector2i(4, 5), true, false, true],
#]
#
#var left_d1_wall = [
	#[Vector2i(15, 5), Vector2i(0, 0), true, false, true], [Vector2i(0, 6), Vector2i(1, 1), true, false, true], 
	#[Vector2i(1, 6), Vector2i(0, 1), true, false, false], [Vector2i(2, 6), Vector2i(2, 2), true, false, true], 
	#[Vector2i(3, 6), Vector2i(1, 2), true, false, false], [Vector2i(4, 6), Vector2i(0, 2), true, false, false],
	#[Vector2i(5, 6), Vector2i(3, 3), true, false, true], [Vector2i(6, 6), Vector2i(2, 3), true, false, false],
	#[Vector2i(7, 6), Vector2i(1, 3), true, false, false], [Vector2i(8, 6), Vector2i(0, 3), true, false, false],
	#[Vector2i(9, 6), Vector2i(3, 4), true, false, false], [Vector2i(10, 6), Vector2i(2, 4), true, false, false],
	#[Vector2i(11, 6), Vector2i(1, 4), true, false, false], [Vector2i(12, 6), Vector2i(0, 4), true, false, false],
	#[Vector2i(13, 6), Vector2i(3, 5), true, false, false], [Vector2i(14, 6), Vector2i(2, 5), true, false, false],
	#[Vector2i(15, 6), Vector2i(1, 5), true, false, false], [Vector2i(0, 7), Vector2i(0, 5), true, false, false],
	#[Vector2i(1, 7), Vector2i(3, 6), true, false, false], [Vector2i(2, 7), Vector2i(2, 6), true, false, false],
	#[Vector2i(3, 7), Vector2i(1, 6), true, false, false], [Vector2i(0, 7), Vector2i(0, 6), true, false, false],
	#[Vector2i(15, 11), Vector2i(3, 7), true, false, false], [Vector2i(0, 12), Vector2i(2, 7), true, false, false],
	#[Vector2i(3, 7), Vector2i(1, 7), true, false, false], [Vector2i(0, 7), Vector2i(0, 7), true, false, false],
	#[Vector2i(1, 7), Vector2i(3, 6), true, false, false], [Vector2i(2, 7), Vector2i(2, 6), true, false, false],
	#[Vector2i(3, 7), Vector2i(1, 6), true, false, false], [Vector2i(0, 7), Vector2i(0, 6), true, false, false],
	#[Vector2i(15, 11), Vector2i(3, 8), true, false, false], [Vector2i(0, 12), Vector2i(2, 8), true, false, false],
	#[Vector2i(3, 7), Vector2i(1, 8), true, false, false], [Vector2i(0, 7), Vector2i(0, 8), true, false, false],
	#[Vector2i(4, 7), Vector2i(3, 9), true, false, true], [Vector2i(5, 7), Vector2i(2, 9), true, false, false],
	#[Vector2i(6, 7), Vector2i(1, 9), true, false, false], [Vector2i(0, 7), Vector2i(0, 9), true, false, false],
	#[Vector2i(7, 7), Vector2i(2, 10), true, false, true], [Vector2i(8, 7), Vector2i(1, 10), true, false, true],
	#[Vector2i(9, 7), Vector2i(0, 10), true, false, true],
#]
#
#var right_d1_wall = [
	#[Vector2i(15, 5), Vector2i(3, 0), false, false, true], [Vector2i(0, 6), Vector2i(2, 1), false, false, true], 
	#[Vector2i(1, 6), Vector2i(3, 1), false, false, false], [Vector2i(2, 6), Vector2i(1, 2), false, false, true], 
	#[Vector2i(3, 6), Vector2i(2, 2), false, false, false], [Vector2i(4, 6), Vector2i(3, 2), false, false, false],
	#[Vector2i(5, 6), Vector2i(0, 3), false, false, true], [Vector2i(6, 6), Vector2i(1, 3), false, false, false],
	#[Vector2i(7, 6), Vector2i(2, 3), false, false, false], [Vector2i(8, 6), Vector2i(3, 3), false, false, false],
	#[Vector2i(9, 6), Vector2i(0, 4), false, false, false], [Vector2i(10, 6), Vector2i(1, 4), false, false, false],
	#[Vector2i(11, 6), Vector2i(2, 4), false, false, false], [Vector2i(12, 6), Vector2i(3, 4), false, false, false],
	#[Vector2i(13, 6), Vector2i(0, 5), false, false, false], [Vector2i(14, 6), Vector2i(1, 5), false, false, false],
	#[Vector2i(15, 6), Vector2i(2, 5), false, false, false], [Vector2i(0, 7), Vector2i(3, 5), false, false, false],
	#[Vector2i(1, 7), Vector2i(0, 6), false, false, false], [Vector2i(2, 7), Vector2i(1, 6), false, false, false],
	#[Vector2i(3, 7), Vector2i(2, 6), false, false, false], [Vector2i(0, 7), Vector2i(3, 6), false, false, false],
	#[Vector2i(15, 11), Vector2i(0, 7), false, false, false], [Vector2i(0, 12), Vector2i(1, 7), false, false, false],
	#[Vector2i(3, 7), Vector2i(2, 7), false, false, false], [Vector2i(0, 7), Vector2i(3, 7), false, false, false],
	#[Vector2i(1, 7), Vector2i(0, 6), false, false, false], [Vector2i(2, 7), Vector2i(1, 6), false, false, false],
	#[Vector2i(3, 7), Vector2i(2, 6), false, false, false], [Vector2i(0, 7), Vector2i(3, 6), false, false, false],
	#[Vector2i(15, 11), Vector2i(0, 8), false, false, false], [Vector2i(0, 12), Vector2i(1, 8), false, false, false],
	#[Vector2i(3, 7), Vector2i(2, 8), false, false, false], [Vector2i(0, 7), Vector2i(3, 8), false, false, false],
	#[Vector2i(4, 7), Vector2i(0, 9), false, false, true], [Vector2i(5, 7), Vector2i(1, 9), false, false, false],
	#[Vector2i(6, 7), Vector2i(2, 9), false, false, false], [Vector2i(0, 7), Vector2i(3, 9), false, false, false],
	#[Vector2i(7, 7), Vector2i(1, 10), false, false, true], [Vector2i(8, 7), Vector2i(2, 10), false, false, true],
	#[Vector2i(9, 7), Vector2i(3, 10), false, false, true],
#]
#
#var flat_d0_wall = [
	#[Vector2i(8, 8), Vector2i(0, 0), false, false, false], [Vector2i(9, 8), Vector2i(1, 0), false, false, false],
	#[Vector2i(10, 8), Vector2i(2, 0), false, false, false], [Vector2i(11, 8), Vector2i(3, 0), false, false, false],
	#[Vector2i(12, 8), Vector2i(4, 0), false, false, false], [Vector2i(1, 12), Vector2i(5, 0), false, false, false],
	#[Vector2i(1, 12), Vector2i(6, 0), false, false, false], [Vector2i(1, 12), Vector2i(7, 0), false, false, false],
	#[Vector2i(13, 8), Vector2i(0, 1), false, false, false], [Vector2i(14, 8), Vector2i(1, 1), false, false, false],
	#[Vector2i(15, 8), Vector2i(2, 1), false, false, false], [Vector2i(0, 9), Vector2i(3, 1), false, false, false],
	#[Vector2i(1, 9), Vector2i(4, 1), false, false, false], [Vector2i(2, 12), Vector2i(5, 1), false, false, false],
	#[Vector2i(2, 12), Vector2i(6, 1), false, false, false], [Vector2i(2, 12), Vector2i(7, 1), false, false, false],
	#[Vector2i(2, 9), Vector2i(0, 2), false, false, false], [Vector2i(3, 9), Vector2i(1, 2), false, false, false],
	#[Vector2i(3, 9), Vector2i(2, 2), false, false, false], [Vector2i(4, 9), Vector2i(3, 2), false, false, false],
	#[Vector2i(3, 9), Vector2i(4, 2), false, false, false], [Vector2i(3, 9), Vector2i(5, 2), false, false, false],
	#[Vector2i(3, 9), Vector2i(6, 2), false, false, false], [Vector2i(3, 9), Vector2i(7, 2), false, false, false],
	#[Vector2i(5, 9), Vector2i(0, 3), false, false, false], [Vector2i(6, 9), Vector2i(1, 3), false, false, false],
	#[Vector2i(6, 9), Vector2i(2, 3), false, false, false], [Vector2i(7, 9), Vector2i(3, 3), false, false, false],
	#[Vector2i(8, 9), Vector2i(4, 3), false, false, false], [Vector2i(3, 12), Vector2i(5, 3), false, false, false],
	#[Vector2i(3, 12), Vector2i(6, 3), false, false, false], [Vector2i(3, 12), Vector2i(7, 3), false, false, false],
	#[Vector2i(5, 9), Vector2i(0, 3), false, false, false], [Vector2i(6, 9), Vector2i(1, 3), false, false, false],
	#[Vector2i(6, 9), Vector2i(2, 3), false, false, false], [Vector2i(7, 9), Vector2i(3, 3), false, false, false],
	#[Vector2i(8, 9), Vector2i(4, 3), false, false, false], [Vector2i(3, 12), Vector2i(5, 3), false, false, false],
	#[Vector2i(3, 12), Vector2i(6, 3), false, false, false], [Vector2i(3, 12), Vector2i(7, 3), false, false, false],
	#[Vector2i(9, 9), Vector2i(0, 4), false, false, false], [Vector2i(10, 9), Vector2i(1, 4), false, false, false],
	#[Vector2i(10, 9), Vector2i(2, 4), false, false, false], [Vector2i(11, 9), Vector2i(3, 4), false, false, false],
	#[Vector2i(12, 9), Vector2i(4, 4), false, false, false], [Vector2i(4, 12), Vector2i(5, 4), false, false, false],
	#[Vector2i(4, 12), Vector2i(6, 4), false, false, false], [Vector2i(4, 12), Vector2i(7, 4), false, false, false],
	#[Vector2i(13, 9), Vector2i(0, 5), false, false, false], [Vector2i(4, 3), Vector2i(1, 5), false, false, false],
	#[Vector2i(4, 3), Vector2i(2, 5), false, false, false], [Vector2i(14, 9), Vector2i(3, 5), false, false, false],
	#[Vector2i(15, 9), Vector2i(4, 5), false, false, false], [Vector2i(5, 12), Vector2i(5, 5), false, false, false],
	#[Vector2i(5, 12), Vector2i(6, 5), false, false, false], [Vector2i(5, 12), Vector2i(7, 5), false, false, false],
	#[Vector2i(13, 9), Vector2i(0, 6), false, false, false], [Vector2i(4, 3), Vector2i(1, 6), false, false, false],
	#[Vector2i(4, 3), Vector2i(2, 6), false, false, false], [Vector2i(14, 9), Vector2i(3, 6), false, false, false],
	#[Vector2i(0, 10), Vector2i(4, 6), false, false, false], [Vector2i(12, 4), Vector2i(5, 6), false, false, false],
	#[Vector2i(12, 4), Vector2i(6, 6), false, false, false], [Vector2i(12, 4), Vector2i(7, 6), false, false, false],
	#[Vector2i(13, 9), Vector2i(0, 7), false, false, false], [Vector2i(4, 3), Vector2i(1, 7), false, false, false],
	#[Vector2i(4, 3), Vector2i(2, 7), false, false, false], [Vector2i(14, 9), Vector2i(3, 7), false, false, false],
	#[Vector2i(0, 10), Vector2i(4, 7), false, false, false], [Vector2i(12, 4), Vector2i(5, 7), false, false, false],
	#[Vector2i(12, 4), Vector2i(6, 7), false, false, false], [Vector2i(12, 4), Vector2i(7, 7), false, false, false],
	#[Vector2i(13, 9), Vector2i(0, 8), false, false, false], [Vector2i(4, 3), Vector2i(1, 8), false, false, false],
	#[Vector2i(4, 3), Vector2i(2, 8), false, false, false], [Vector2i(14, 9), Vector2i(3, 8), false, false, false],
	#[Vector2i(0, 10), Vector2i(4, 8), false, false, false], [Vector2i(12, 4), Vector2i(5, 8), false, false, false],
	#[Vector2i(12, 4), Vector2i(6, 8), false, false, false], [Vector2i(12, 4), Vector2i(7, 8), false, false, false],
	#[Vector2i(13, 9), Vector2i(0, 9), false, false, false], [Vector2i(4, 3), Vector2i(1, 9), false, false, false],
	#[Vector2i(4, 3), Vector2i(2, 9), false, false, false], [Vector2i(14, 9), Vector2i(3, 9), false, false, false],
	#[Vector2i(0, 10), Vector2i(4, 9), false, false, false], [Vector2i(12, 4), Vector2i(5, 9), false, false, false],
	#[Vector2i(12, 4), Vector2i(6, 9), false, false, false], [Vector2i(12, 4), Vector2i(7, 9), false, false, false],
	#[Vector2i(1, 10), Vector2i(0, 10), false, false, false], [Vector2i(2, 10), Vector2i(1, 10), false, false, false],
	#[Vector2i(2, 10), Vector2i(2, 10), false, false, false], [Vector2i(3, 10), Vector2i(3, 10), false, false, false],
	#[Vector2i(4, 10), Vector2i(4, 10), false, false, false], [Vector2i(6, 12), Vector2i(5, 10), false, false, false],
	#[Vector2i(6, 12), Vector2i(6, 10), false, false, false], [Vector2i(6, 12), Vector2i(7, 10), false, false, false],
	#
	#[Vector2i(8, 8), Vector2i(15, 0), true, false, false], [Vector2i(9, 8), Vector2i(14, 0), true, false, false],
	#[Vector2i(10, 8), Vector2i(13, 0), true, false, false], [Vector2i(11, 8), Vector2i(12, 0), true, false, false],
	#[Vector2i(12, 8), Vector2i(11, 0), true, false, false], [Vector2i(1, 12), Vector2i(10, 0), true, false, false],
	#[Vector2i(1, 12), Vector2i(9, 0), true, false, false], [Vector2i(1, 12), Vector2i(8, 0), true, false, false],
	#[Vector2i(13, 8), Vector2i(15, 1), true, false, false], [Vector2i(14, 8), Vector2i(14, 1), true, false, false],
	#[Vector2i(15, 8), Vector2i(13, 1), true, false, false], [Vector2i(0, 9), Vector2i(12, 1), true, false, false],
	#[Vector2i(1, 9), Vector2i(11, 1), true, false, false], [Vector2i(2, 12), Vector2i(10, 1), true, false, false],
	#[Vector2i(2, 12), Vector2i(9, 1), true, false, false], [Vector2i(2, 12), Vector2i(8, 1), true, false, false],
	#[Vector2i(2, 9), Vector2i(15, 2), true, false, false], [Vector2i(3, 9), Vector2i(14, 2), true, false, false],
	#[Vector2i(3, 9), Vector2i(13, 2), true, false, false], [Vector2i(4, 9), Vector2i(12, 2), true, false, false],
	#[Vector2i(3, 9), Vector2i(11, 2), true, false, false], [Vector2i(3, 9), Vector2i(10, 2), true, false, false],
	#[Vector2i(3, 9), Vector2i(9, 2), true, false, false], [Vector2i(3, 9), Vector2i(8, 2), true, false, false],
	#[Vector2i(5, 9), Vector2i(15, 3), true, false, false], [Vector2i(6, 9), Vector2i(14, 3), true, false, false],
	#[Vector2i(6, 9), Vector2i(13, 3), true, false, false], [Vector2i(7, 9), Vector2i(12, 3), true, false, false],
	#[Vector2i(8, 9), Vector2i(11, 3), true, false, false], [Vector2i(3, 12), Vector2i(10, 3), true, false, false],
	#[Vector2i(3, 12), Vector2i(9, 3), true, false, false], [Vector2i(3, 12), Vector2i(8, 3), true, false, false],
	#[Vector2i(5, 9), Vector2i(15, 3), true, false, false], [Vector2i(6, 9), Vector2i(14, 3), true, false, false],
	#[Vector2i(6, 9), Vector2i(13, 3), true, false, false], [Vector2i(7, 9), Vector2i(12, 3), true, false, false],
	#[Vector2i(8, 9), Vector2i(11, 3), true, false, false], [Vector2i(3, 12), Vector2i(10, 3), true, false, false],
	#[Vector2i(3, 12), Vector2i(9, 3), true, false, false], [Vector2i(3, 12), Vector2i(8, 3), true, false, false],
	#[Vector2i(9, 9), Vector2i(15, 4), true, false, false], [Vector2i(10, 9), Vector2i(14, 4), true, false, false],
	#[Vector2i(10, 9), Vector2i(13, 4), true, false, false], [Vector2i(11, 9), Vector2i(12, 4), true, false, false],
	#[Vector2i(12, 9), Vector2i(11, 4), true, false, false], [Vector2i(4, 12), Vector2i(10, 4), true, false, false],
	#[Vector2i(4, 12), Vector2i(9, 4), true, false, false], [Vector2i(4, 12), Vector2i(8, 4), true, false, false],
	#[Vector2i(13, 9), Vector2i(15, 5), true, false, false], [Vector2i(4, 3), Vector2i(14, 5), true, false, false],
	#[Vector2i(4, 3), Vector2i(13, 5), true, false, false], [Vector2i(14, 9), Vector2i(12, 5), true, false, false],
	#[Vector2i(15, 9), Vector2i(11, 5), true, false, false], [Vector2i(5, 12), Vector2i(10, 5), true, false, false],
	#[Vector2i(5, 12), Vector2i(9, 5), true, false, false], [Vector2i(5, 12), Vector2i(8, 5), true, false, false],
	#[Vector2i(13, 9), Vector2i(15, 6), true, false, false], [Vector2i(4, 3), Vector2i(14, 6), true, false, false],
	#[Vector2i(4, 3), Vector2i(13, 6), true, false, false], [Vector2i(14, 9), Vector2i(12, 6), true, false, false],
	#[Vector2i(0, 10), Vector2i(11, 6), true, false, false], [Vector2i(12, 4), Vector2i(10, 6), true, false, false],
	#[Vector2i(12, 4), Vector2i(9, 6), true, false, false], [Vector2i(12, 4), Vector2i(8, 6), true, false, false],
	#[Vector2i(13, 9), Vector2i(15, 7), true, false, false], [Vector2i(4, 3), Vector2i(14, 7), true, false, false],
	#[Vector2i(4, 3), Vector2i(13, 7), true, false, false], [Vector2i(14, 9), Vector2i(12, 7), true, false, false],
	#[Vector2i(0, 10), Vector2i(11, 7), true, false, false], [Vector2i(12, 4), Vector2i(10, 7), true, false, false],
	#[Vector2i(12, 4), Vector2i(9, 7), true, false, false], [Vector2i(12, 4), Vector2i(8, 7), true, false, false],
	#[Vector2i(13, 9), Vector2i(15, 8), true, false, false], [Vector2i(4, 3), Vector2i(14, 8), true, false, false],
	#[Vector2i(4, 3), Vector2i(13, 8), true, false, false], [Vector2i(14, 9), Vector2i(12, 8), true, false, false],
	#[Vector2i(0, 10), Vector2i(11, 8), true, false, false], [Vector2i(12, 4), Vector2i(10, 8), true, false, false],
	#[Vector2i(12, 4), Vector2i(9, 8), true, false, false], [Vector2i(12, 4), Vector2i(8, 8), true, false, false],
	#[Vector2i(13, 9), Vector2i(15, 9), true, false, false], [Vector2i(4, 3), Vector2i(14, 9), true, false, false],
	#[Vector2i(4, 3), Vector2i(13, 9), true, false, false], [Vector2i(14, 9), Vector2i(12, 9), true, false, false],
	#[Vector2i(0, 10), Vector2i(11, 9), true, false, false], [Vector2i(12, 4), Vector2i(10, 9), true, false, false],
	#[Vector2i(12, 4), Vector2i(9, 9), true, false, false], [Vector2i(12, 4), Vector2i(8, 9), true, false, false],
	#[Vector2i(1, 10), Vector2i(15, 10), true, false, false], [Vector2i(2, 10), Vector2i(14, 10), true, false, false],
	#[Vector2i(2, 10), Vector2i(13, 10), true, false, false], [Vector2i(3, 10), Vector2i(12, 10), true, false, false],
	#[Vector2i(4, 10), Vector2i(11, 10), true, false, false], [Vector2i(6, 12), Vector2i(10, 10), true, false, false],
	#[Vector2i(6, 12), Vector2i(9, 10), true, false, false], [Vector2i(6, 12), Vector2i(8, 10), true, false, false],
#]
#
#var right_d0_wall = [
	#[Vector2i(0, 3), Vector2i(0, 0), false, false, false], [Vector2i(1, 3), Vector2i(1, 0), false, false, false],
	#[Vector2i(2, 3), Vector2i(2, 0), false, false, false], [Vector2i(3, 3), Vector2i(3, 0), false, false, false],
	#[Vector2i(4, 3), Vector2i(4, 0), false, false, false], [Vector2i(5, 3), Vector2i(5, 0), false, false, false],
	#[Vector2i(6, 3), Vector2i(6, 0), false, false, false], [Vector2i(7, 3), Vector2i(7, 0), false, false, false],
	#
	#[Vector2i(8, 3), Vector2i(0, 1), false, false, false], [Vector2i(9, 3), Vector2i(1, 1), false, false, false],
	#[Vector2i(10, 3), Vector2i(2, 1), false, false, false], [Vector2i(11, 3), Vector2i(3, 1), false, false, false],
	#[Vector2i(12, 3), Vector2i(4, 1), false, false, false], [Vector2i(13, 3), Vector2i(5, 1), false, false, false],
	#[Vector2i(14, 3), Vector2i(6, 1), false, false, false], [Vector2i(15, 3), Vector2i(7, 1), false, false, false],
	#
	#[Vector2i(0, 4), Vector2i(0, 2), false, false, false], [Vector2i(1, 4), Vector2i(1, 2), false, false, false],
	#[Vector2i(2, 4), Vector2i(2, 2), false, false, false], [Vector2i(3, 4), Vector2i(3, 2), false, false, false],
	#[Vector2i(4, 4), Vector2i(4, 2), false, false, false], [Vector2i(5, 4), Vector2i(5, 2), false, false, false],
	#[Vector2i(0, 4), Vector2i(6, 2), false, false, false], [Vector2i(6, 4), Vector2i(7, 2), false, false, false],
	#
	#[Vector2i(7, 4), Vector2i(0, 3), false, false, false], [Vector2i(8, 4), Vector2i(1, 3), false, false, false],
	#[Vector2i(9, 4), Vector2i(2, 3), false, false, false], [Vector2i(10, 4), Vector2i(3, 3), false, false, false],
	#[Vector2i(11, 4), Vector2i(4, 3), false, false, false], [Vector2i(12, 4), Vector2i(5, 3), false, false, false],
	#[Vector2i(0, 4), Vector2i(6, 3), false, false, false], [Vector2i(6, 4), Vector2i(7, 3), false, false, false],
	#
	#[Vector2i(13, 4), Vector2i(0, 4), false, false, false], [Vector2i(14, 4), Vector2i(1, 4), false, false, false],
	#[Vector2i(15, 4), Vector2i(2, 4), false, false, false], [Vector2i(0, 5), Vector2i(3, 4), false, false, false],
	#[Vector2i(1, 5), Vector2i(4, 4), false, false, false], [Vector2i(12, 4), Vector2i(5, 4), false, false, false],
	#[Vector2i(0, 4), Vector2i(6, 4), false, false, false], [Vector2i(6, 4), Vector2i(7, 4), false, false, false],
	#
	#[Vector2i(0, 4), Vector2i(0, 5), false, false, false], [Vector2i(14, 4), Vector2i(1, 5), false, false, false],
	#[Vector2i(15, 4), Vector2i(2, 5), false, false, false], [Vector2i(3, 5), Vector2i(3, 5), false, false, false],
	#[Vector2i(4, 5), Vector2i(4, 5), false, false, false], [Vector2i(12, 4), Vector2i(5, 5), false, false, false],
	#[Vector2i(0, 4), Vector2i(6, 5), false, false, false], [Vector2i(6, 4), Vector2i(7, 5), false, false, false],
	#
	#[Vector2i(0, 4), Vector2i(0, 6), false, false, false], [Vector2i(14, 4), Vector2i(1, 6), false, false, false],
	#[Vector2i(15, 4), Vector2i(2, 6), false, false, false], [Vector2i(3, 5), Vector2i(3, 6), false, false, false],
	#[Vector2i(4, 5), Vector2i(4, 6), false, false, false], [Vector2i(12, 4), Vector2i(5, 6), false, false, false],
	#[Vector2i(0, 4), Vector2i(6, 6), false, false, false], [Vector2i(6, 4), Vector2i(7, 6), false, false, false],
	#
	#[Vector2i(0, 4), Vector2i(0, 7), false, false, false], [Vector2i(14, 4), Vector2i(1, 7), false, false, false],
	#[Vector2i(15, 4), Vector2i(2, 7), false, false, false], [Vector2i(3, 5), Vector2i(3, 7), false, false, false],
	#[Vector2i(4, 5), Vector2i(4, 7), false, false, false], [Vector2i(12, 4), Vector2i(5, 7), false, false, false],
	#[Vector2i(0, 4), Vector2i(6, 7), false, false, false], [Vector2i(6, 4), Vector2i(7, 7), false, false, false],
	#
	#[Vector2i(0, 4), Vector2i(0, 8), false, false, false], [Vector2i(14, 4), Vector2i(1, 8), false, false, false],
	#[Vector2i(15, 4), Vector2i(2, 8), false, false, false], [Vector2i(3, 5), Vector2i(3, 8), false, false, false],
	#[Vector2i(4, 5), Vector2i(4, 8), false, false, false], [Vector2i(12, 4), Vector2i(5, 8), false, false, false],
	#[Vector2i(0, 4), Vector2i(6, 8), false, false, false], [Vector2i(6, 4), Vector2i(7, 8), false, false, false],
	#
	#[Vector2i(0, 4), Vector2i(0, 9), false, false, false], [Vector2i(14, 4), Vector2i(1, 9), false, false, false],
	#[Vector2i(15, 4), Vector2i(2, 9), false, false, false], [Vector2i(3, 5), Vector2i(3, 9), false, false, false],
	#[Vector2i(4, 5), Vector2i(4, 9), false, false, false], [Vector2i(12, 4), Vector2i(5, 9), false, false, false],
	#[Vector2i(0, 4), Vector2i(6, 9), false, false, false], [Vector2i(6, 4), Vector2i(7, 9), false, false, false],
	#
	#[Vector2i(2, 5), Vector2i(0, 10), false, false, false], [Vector2i(14, 4), Vector2i(1, 10), false, false, false],
	#[Vector2i(15, 4), Vector2i(2, 10), false, false, false], [Vector2i(3, 5), Vector2i(3, 10), false, false, false],
	#[Vector2i(4, 5), Vector2i(4, 10), false, false, false], [Vector2i(12, 4), Vector2i(5, 10), false, false, false],
	#[Vector2i(0, 4), Vector2i(6, 10), false, false, false], [Vector2i(6, 4), Vector2i(7, 10), false, false, false],
	#
	#[Vector2i(5, 5), Vector2i(0, 11), false, false, true], [Vector2i(6, 5), Vector2i(1, 11), false, false, true],
	#[Vector2i(7, 5), Vector2i(2, 11), false, false, true], [Vector2i(8, 5), Vector2i(3, 11), false, false, true],
	#[Vector2i(9, 5), Vector2i(4, 11), false, false, true], [Vector2i(10, 5), Vector2i(5, 11), false, false, false],
	#[Vector2i(0, 4), Vector2i(6, 11), false, false, false], [Vector2i(6, 4), Vector2i(7, 11), false, false, false],
	#
	#[Vector2i(11, 5), Vector2i(5, 12), false, false, true],
	#[Vector2i(12, 5), Vector2i(6, 12), false, false, false], [Vector2i(6, 4), Vector2i(7, 12), false, false, false],
	#
	#[Vector2i(13, 5), Vector2i(6, 13), false, false, true], [Vector2i(14, 5), Vector2i(7, 13), false, false, true],
#]

#endregion
