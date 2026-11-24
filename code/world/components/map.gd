extends WorldComponentBase


enum PlayerState {
	STANDING,
	MOVING,
	TURNING
}

var map: DungeonMapResource = null
var _loaded_map: String = ""
var _move_progress := 0.0
var _reachable_cells: Array[Vector2i]= []

var _layer: int
var _player_pos: Vector2i
var _player_facing: int
var _moving: bool
var _move_dir: Vector2i
var _turning: int
var _turn_dir: int


func _init() -> void:
	_observed_states = [
		"world", "world.layer", "world.map", "world.stage", "world.player.position",
		"world.player.facing", "input.moving", "input.turning"
	]


func _process(delta: float) -> void:
	if !map:
		return
	
	var state := get_player_state()
	var culled_data := []
	var sub_offset_x: int = 0 
	
	match state:
		PlayerState.STANDING:
			culled_data = DungeonRenderUtils.get_default_render_batch(_player_pos, _player_facing, map, _reachable_cells)
		
		PlayerState.MOVING:
			if _move_progress <= 0.5:
				culled_data = DungeonRenderUtils.get_step_render_batch(_player_pos, _player_facing, map, _reachable_cells)
			else:
				var next_pos = _player_pos + _move_dir
				_reachable_cells = map.get_reachable_cells(next_pos)
				culled_data = DungeonRenderUtils.get_default_render_batch(next_pos, _player_facing, map, _reachable_cells)
		
		PlayerState.TURNING:
			var target_facing = _loop_between(_player_facing + _turn_dir, 0, 4)
			
			if _move_progress <= 0.25:
				var slide_x = lerpf(0.0, -1.0, _move_progress * 4)
				sub_offset_x = roundi(8 * _turn_dir * slide_x)
				culled_data = DungeonRenderUtils.get_default_render_batch(_player_pos, _player_facing, map, _reachable_cells)
			elif _move_progress <= 0.75:
				var slide_x = lerpf(1.0, -1.0, (_move_progress - 0.25) * 2)
				sub_offset_x = roundi(16 * _turn_dir * slide_x)
				culled_data = DungeonRenderUtils.get_turning_render_batch(_player_pos, _player_facing, target_facing, map, _reachable_cells)
			else:
				var slide_x = lerpf(1.0, 0.0, (_move_progress - 0.75) * 4)
				sub_offset_x = roundi(16 * _turn_dir * slide_x)
				culled_data = DungeonRenderUtils.get_default_render_batch(_player_pos, target_facing, map, _reachable_cells)
	
	update_move_progress(delta)
	
	for line in culled_data:
		var wall_height: int = $Tileset.get_wall_height(line[0])
		var grid_pos: Vector2i = (Vector2i(0, 2 - wall_height) + line[1]) * Splatmap.Vram.CELL_SIZE
		Splatmap.add_immediate(SplatDrawComplexCmd.new($Tileset.get_complex_wall(line[0]), Vector2i(sub_offset_x, 0) + grid_pos, _layer, false))
	
	if _move_progress == 1.0:
		var new_turning = maxi(0, _turning - 1)
		if _moving:
			owner.set_state("world.player.position", _player_pos + _move_dir)
			owner.set_state("input.moving", false)
		if _turning != new_turning:
			var target_facing = _loop_between(_player_facing + _turn_dir, 0, 4)
			if new_turning > 0:
				_move_progress = 0.0
			owner.set_state("world.player.facing", target_facing)
			owner.set_state("input.turning", new_turning)


func update_move_progress(delta: float) -> void:
	# Clamp to [0,1] and apply delta based on state
	if _moving or _turning > 0:
		_move_progress = clampf(_move_progress + (delta * (3.0 if _moving else 2.0)), 0.0, 1.0)
	else:
		_move_progress = clampf(_move_progress + delta, 0.0, 1.0)


func update() -> void:
	var map_name: String = owner.get_state("world.map", "")
	if map_name != _loaded_map:
		_update_map(map_name)
	
	if !map:
		return
	
	_update_input()
	_update_world()


func get_edge(position: Vector2i, facing: int) -> DungeonEdgeResource:
	if map == null:
		return null
	
	return map.get_edge(position, facing)


func _update_map(map_name: String) -> void:
	map = load(map_name)
	_loaded_map = map_name
	
	if map.tileset_ref == "":
		return
	
	owner.set_state("world.player.position", map.find_pos_with_tag(&"spawn"))
	
	# This section is funky as hell and there's probably a better way...
	var tileset_parent := $Tileset
	var tileset: LevelTileset = load(map.tileset_ref).new()
	tileset_parent.set_script(tileset.get_script())
	
	$Tileset.write_to_vram(Splatmap._vram, Vector2i(0, 14))
	Splatmap.write_to_vram(load(map.sky_strip_ref), Vector2i(31, 0))
	
	for y in range(2, 16, 1):
		Splatmap.register_draw(SplatDrawLineCmd.new(Vector2i(31, y - 2), y, 1))


func _update_input() -> void:
	_moving = owner.get_state("input.moving", false)
	if _moving:
		_move_progress = 0.0
	_move_dir = owner.get_state("input.move_dir", Vector2i())
	_turning = owner.get_state("input.turning", 0)
	if _turning > 0:
		_move_progress = 0.0
	
	_turn_dir = owner.get_state("input.turn_dir", 0)


func _update_world() -> void:
	_layer = owner.get_state("world.layer", 1)
	var new_player_pos: Vector2i = owner.get_state("world.player.position", Vector2i())
	if new_player_pos != _player_pos:
		_player_pos = new_player_pos
		_reachable_cells = map.get_reachable_cells(_player_pos)
	_player_facing = owner.get_state("world.player.facing", 0)


func get_player_state() -> PlayerState:
	if _moving:
		return PlayerState.MOVING
	elif _turning > 0:
		return PlayerState.TURNING
	else:
		return PlayerState.STANDING


func _loop_between(v: int, min_v: int, max_v: int) -> int:
	while v >= max_v:
		v -= max_v
	while v < min_v:
		v += max_v
	return v
