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
		# DEFAULT PERSPECTIVE
		"f_d0": _baked_walls[key] =    _build_flat_wall(0)
		"df_d0": _baked_walls[key] =   _build_flat_wall(1)
		"l_d0": _baked_walls[key] =    _build_left_wall(2)
		"dl_d0": _baked_walls[key] =   _build_left_wall(3)
		"r_d0": _baked_walls[key] =   _build_right_wall(2)
		"dr_d0": _baked_walls[key] =  _build_right_wall(3)
		"f_d1": _baked_walls[key] =    _build_flat_wall(4)
		"df_d1": _baked_walls[key] =   _build_flat_wall(5)
		"l_d1": _baked_walls[key] =    _build_left_wall(6)
		"dl_d1": _baked_walls[key] =   _build_left_wall(7)
		"l1_d1": _baked_walls[key] =   _build_left_wall(8)
		"r_d1": _baked_walls[key] =   _build_right_wall(6)
		"dr_d1": _baked_walls[key] =  _build_right_wall(7)
		"r1_d1": _baked_walls[key] =  _build_right_wall(8)
		"f_d2": _baked_walls[key] =    _build_flat_wall(9)
		"df_d2": _baked_walls[key] =  _build_flat_wall(10)
		"l_d2": _baked_walls[key] =   _build_left_wall(11)
		"dl_d2": _baked_walls[key] =  _build_left_wall(12)
		"l1_d2": _baked_walls[key] =  _build_left_wall(13)
		"r_d2": _baked_walls[key] =  _build_right_wall(11)
		"dr_d2": _baked_walls[key] = _build_right_wall(12)
		"r1_d2": _baked_walls[key] = _build_right_wall(13)
		"l_d3": _baked_walls[key] =   _build_left_wall(14)
		"l1_d3": _baked_walls[key] =  _build_left_wall(15)
		"r_d3": _baked_walls[key] =  _build_right_wall(14)
		"r1_d3": _baked_walls[key] = _build_right_wall(15)
		
		# TURNING PERSPECTIVE
		"tl_d0": _baked_walls[key] =  _build_left_wall(16)
		"dtl_d0": _baked_walls[key] = _build_left_wall(17)
		"tr_d0": _baked_walls[key] = _build_right_wall(16)
		"dtr_d0": _baked_walls[key] = _build_right_wall(17)
		"tl_d1": _baked_walls[key] =  _build_left_wall(18)
		"dtl_d1": _baked_walls[key] = _build_left_wall(19)
		"tr_d1": _baked_walls[key] = _build_right_wall(18)
		"dtr_d1": _baked_walls[key] = _build_right_wall(19)
		"tr1_d1": _baked_walls[key] = _build_right_wall(20)
		"dtr1_d1": _baked_walls[key] = _build_right_wall(20)
		"tl1_d1": _baked_walls[key] =  _build_left_wall(20)
		"dtl1_d1": _baked_walls[key] = _build_left_wall(20)
		"tl_d2": _baked_walls[key] =  _build_left_wall(21)
		"dtl_d2": _baked_walls[key] = _build_left_wall(22)
		"tr_d2": _baked_walls[key] = _build_right_wall(21)
		"dtr_d2": _baked_walls[key] = _build_right_wall(22)
		"tr1_d2": _baked_walls[key] = _build_right_wall(23)
		"dtr1_d2": _baked_walls[key] = _build_right_wall(24)
		"tl1_d2": _baked_walls[key] =  _build_left_wall(23)
		"dtl1_d2": _baked_walls[key] = _build_left_wall(24)
		"tl_d3": _baked_walls[key] =  _build_left_wall(25)
		"dtl_d3": _baked_walls[key] = _build_left_wall(25)
		"tr_d3": _baked_walls[key] = _build_right_wall(25)
		"dtr_d3": _baked_walls[key] = _build_right_wall(25)
		
		# STEPPING PERSPECTIVE
		"sf_d0": _baked_walls[key] = _build_flat_wall(26)
		"dsf_d0": _baked_walls[key] = _build_flat_wall(27)
		"sr_d0": _baked_walls[key] = _build_right_wall(28)
		"dsr_d0": _baked_walls[key] = _build_right_wall(28)
		"sl_d0": _baked_walls[key] = _build_left_wall(28)
		"dsl_d0": _baked_walls[key] = _build_left_wall(28)
		"sf_d1": _baked_walls[key] = _build_flat_wall(29)
		"dsf_d1": _baked_walls[key] = _build_flat_wall(30)
		"sr_d1": _baked_walls[key] = _build_right_wall(31)
		"dsr_d1": _baked_walls[key] = _build_right_wall(32)
		"sl_d1": _baked_walls[key] = _build_left_wall(31)
		"dsl_d1": _baked_walls[key] = _build_left_wall(32)
		"sf_d2": _baked_walls[key] = _build_flat_wall(33)
		"dsf_d2": _baked_walls[key] = _build_flat_wall(34)
		"sr_d2": _baked_walls[key] = _build_right_wall(35)
		"dsr_d2": _baked_walls[key] = _build_right_wall(36)
		"sl_d2": _baked_walls[key] = _build_left_wall(35)
		"dsl_d2": _baked_walls[key] = _build_left_wall(36)
		"sr_d3": _baked_walls[key] = _build_right_wall(37)
		"dsr_d3": _baked_walls[key] = _build_right_wall(38)
		"sl_d3": _baked_walls[key] = _build_left_wall(37)
		"dsl_d3": _baked_walls[key] = _build_left_wall(38)
		"sr1_d2": _baked_walls[key] = _build_right_wall(39)
		"dsr1_d2": _baked_walls[key] = _build_right_wall(39)
		"sl1_d2": _baked_walls[key] = _build_left_wall(39)
		"dsl1_d2": _baked_walls[key] = _build_left_wall(39)
		"sr1_d3": _baked_walls[key] = _build_right_wall(40)
		"dsr1_d3": _baked_walls[key] = _build_right_wall(40)
		"sl1_d3": _baked_walls[key] = _build_left_wall(40)
		"dsl1_d3": _baked_walls[key] = _build_left_wall(40)
	
	return _baked_walls[key]


func get_wall_height(key: String) -> int:
	match key:
		# DEFAULT PERSPECTIVE
		"f_d0": return _get_region_height(0)
		"df_d0": return _get_region_height(1)
		"l_d0": return _get_region_height(2)
		"dl_d0": return _get_region_height(3)
		"r_d0": return _get_region_height(2)
		"dr_d0": return _get_region_height(3)
		"f_d1": return _get_region_height(4)
		"df_d1": return _get_region_height(5)
		"l_d1": return _get_region_height(6)
		"dl_d1": return _get_region_height(7)
		"l1_d1": return _get_region_height(8)
		"r_d1": return _get_region_height(6)
		"dr_d1": return _get_region_height(7)
		"r1_d1": return _get_region_height(8)
		"f_d2": return _get_region_height(9)
		"df_d2": return _get_region_height(10)
		"l_d2": return _get_region_height(11)
		"dl_d2": return _get_region_height(12)
		"l1_d2": return _get_region_height(13)
		"r_d2": return _get_region_height(11)
		"dr_d2": return _get_region_height(12)
		"r1_d2": return _get_region_height(13)
		"l_d3": return _get_region_height(14)
		"l1_d3": return _get_region_height(15)
		"r_d3": return _get_region_height(14)
		"r1_d3": return _get_region_height(15)
		
		# TURNING PERSPECTIVE
		"tl_d0": return _get_region_height(16)
		"dtl_d0": return _get_region_height(17)
		"tr_d0": return _get_region_height(16)
		"dtr_d0": return _get_region_height(17)
		"tl_d1": return _get_region_height(18)
		"dtl_d1": return _get_region_height(19)
		"tr_d1": return _get_region_height(18)
		"dtr_d1": return _get_region_height(19)
		"tr1_d1": return _get_region_height(20)
		"tl1_d1": return _get_region_height(20)
		"dtr1_d1": return _get_region_height(20)
		"dtl1_d1": return _get_region_height(20)
		"tl_d2": return _get_region_height(21)
		"dtl_d2": return _get_region_height(22)
		"tr_d2": return _get_region_height(21)
		"dtr_d2": return _get_region_height(22)
		"tl1_d2": return _get_region_height(23)
		"dtl1_d2": return _get_region_height(24)
		"tr1_d2": return _get_region_height(23)
		"dtr1_d2": return _get_region_height(24)
		"tl_d3": return _get_region_height(25)
		"dtl_d3": return _get_region_height(25)
		"tr_d3": return _get_region_height(25)
		"dtr_d3": return _get_region_height(25)
		
		# STEPPING PERSPECTIVE
		"sf_d0": return _get_region_height(26)
		"dsf_d0": return _get_region_height(27)
		"sr_d0": return _get_region_height(28)
		"dsr_d0": return _get_region_height(28)
		"sl_d0": return _get_region_height(28)
		"dsl_d0": return _get_region_height(28)
		"sf_d1": return _get_region_height(29)
		"dsf_d1": return _get_region_height(30)
		"sr_d1": return _get_region_height(31)
		"dsr_d1": return _get_region_height(32)
		"sl_d1": return _get_region_height(31)
		"dsl_d1": return _get_region_height(32)
		"sf_d2": return _get_region_height(33)
		"dsf_d2": return _get_region_height(34)
		"sr_d2": return _get_region_height(35)
		"dsr_d2": return _get_region_height(36)
		"sl_d2": return _get_region_height(35)
		"dsl_d2": return _get_region_height(36)
		"sr_d3": return _get_region_height(37)
		"dsr_d3": return _get_region_height(38)
		"sl_d3": return _get_region_height(37)
		"dsl_d3": return _get_region_height(38)
		"sr1_d2": return _get_region_height(39)
		"dsr1_d2": return _get_region_height(39)
		"sl1_d2": return _get_region_height(39)
		"dsl1_d2": return _get_region_height(39)
		"sr1_d3": return _get_region_height(40)
		"dsr1_d3": return _get_region_height(40)
		"sl1_d3": return _get_region_height(40)
		"dsl1_d3": return _get_region_height(40)
	return 0


func _get_region_height(region: int) -> int:
	if tileset == null:
		return 0
	
	var region_cell_size: Vector2i = tileset.regions[region].size / tileset.tile_size
	return region_cell_size.y


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
