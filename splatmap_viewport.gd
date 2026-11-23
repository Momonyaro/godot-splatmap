extends TextureRect

@export var clear_color := Color.BLACK
@export var test_sky: Texture2D
@export var test_map: DungeonMapResource
@export var debug_vram_view: TextureRect

var _last_parent_size := Vector2()

var _player_pos := Vector2()
var _target_pos := Vector2i()
var _player_facing := DungeonDirection.Facing.SOUTH : set = _set_player_facing
var _target_facing := DungeonDirection.Facing.SOUTH
var _reachable_cells: Array[Vector2i]= []

var _turning := 0
var _turn_dir := 0
var _move_progress := 0.0

var _stepping := false

var _sub_offset := Vector2i()


func _enter_tree() -> void:
	visible = false
	var shader_map: ShaderMaterial = material
	shader_map.set_shader_parameter("tex", Splatmap.get_render_target())


func _ready() -> void:
	Splatmap.clear_color = clear_color
	#Splatmap.set_layer_effect(0, "wavy", SplatWavyEffect.new())
	_resize.call_deferred()
	visible = true
	return
	# Draw Sky
	for y in range(2, 16, 1):
		Splatmap.register_draw(SplatDrawLineCmd.new(Vector2i(31, y - 2), y, 0))
	
	_player_pos = test_map.find_pos_with_tag(&"spawn")
	_reachable_cells = test_map.get_reachable_cells(_player_pos)


func _process(delta: float) -> void:
	if debug_vram_view:
		debug_vram_view.texture = ImageTexture.create_from_image(Splatmap._vram._data)
	return
	var culled_data := []
	
	if _stepping:
		if _move_progress <= 0.5:
			culled_data = DungeonRenderUtils.get_step_render_batch(_player_pos, _player_facing, test_map, _reachable_cells)
		else:
			_player_pos = _target_pos
			_reachable_cells = test_map.get_reachable_cells(_player_pos)
			culled_data = DungeonRenderUtils.get_default_render_batch(_player_pos, _player_facing, test_map, _reachable_cells)
		_sub_offset.x = 0
		_move_progress = clampf(_move_progress + delta * 3, 0.0, 1.0)
	elif _turning > 0:
		if _move_progress <= 0.25:
			var slide_x := lerpf(0.0, -1.0, _move_progress * 4)
			_sub_offset.x = roundi(8 * _turn_dir * slide_x)
			culled_data = DungeonRenderUtils.get_default_render_batch(_player_pos, _player_facing, test_map, _reachable_cells)
		elif _move_progress <= 0.75:
			var slide_x := lerpf(1.0, -1.0, (_move_progress - 0.25) * 2)
			_sub_offset.x = roundi(16 * _turn_dir * slide_x)
			culled_data = DungeonRenderUtils.get_turning_render_batch(_player_pos, _player_facing, _target_facing, test_map, _reachable_cells)
		else:
			_player_facing = _target_facing
			var slide_x := lerpf(1.0, 0.0, (_move_progress - 0.75) * 4)
			_sub_offset.x = roundi(8 * _turn_dir * slide_x)
			culled_data = DungeonRenderUtils.get_default_render_batch(_player_pos, _player_facing, test_map, _reachable_cells)
		_move_progress = clampf(_move_progress + delta * 2, 0.0, 1.0)
	else:
		#culled_data = DungeonRenderUtils.get_step_render_batch(_player_pos, _player_facing, test_map)
		culled_data = DungeonRenderUtils.get_default_render_batch(_player_pos, _player_facing, test_map, _reachable_cells)
		_move_progress = clampf(_move_progress + delta, 0.0, 1.0)
		
	if _move_progress == 1.0:
		_turning = maxi(0, _turning - 1)
		_sub_offset.x = 0
		if _stepping:
			_stepping = false
		if _turning > 0:
			_target_facing = _player_facing + _turn_dir
			if _target_facing >= 4: _target_facing -= 4
			if _target_facing < 0: _target_facing += 4
			_move_progress = 0.0
	
	for line in culled_data:
		var wall_h: int = $Tileset.get_wall_height(line[0])
		var grid_pos: Vector2i = (Vector2i(0, 2 - wall_h) + line[1]) * Splatmap.Vram.CELL_SIZE
		Splatmap.add_immediate(SplatDrawComplexCmd.new($Tileset.get_complex_wall(line[0]), _sub_offset + grid_pos, 0, false))
	
	var parent := get_parent_control()
	if parent and parent.size != _last_parent_size:
		_resize()


func _set_player_facing(value: DungeonDirection.Facing) -> void:
	if _player_facing != value:
		get_tree().root.get_node("/root/TEST_SCENE/Game").set_state("world.player.facing", value)
	
	_player_facing = value


func _resize() -> void:
	_resize_pixel_perfect()
	_place_at_center()


func _resize_pixel_perfect() -> void:
	var parent := get_parent_control()
	var parent_size := parent.size
	
	var splatmap_size: Vector2i = ProjectSettings.get_setting("splatmap/canvas_size")
	var ratio_x := floori(parent_size.x / splatmap_size.x)
	var ratio_y := floori(parent_size.y / splatmap_size.y)
	var lowest_common := maxi(mini(ratio_x, ratio_y), 1)
	size = splatmap_size * lowest_common
	_last_parent_size = parent_size


func _place_at_center() -> void:
	var parent := get_parent_control()
	var parent_size := parent.size
	
	var x_pos := roundi((parent_size.x - size.x) / 2.0)
	var y_pos := roundi((parent_size.y - size.y) / 2.0)
	position = Vector2i(x_pos, y_pos)
