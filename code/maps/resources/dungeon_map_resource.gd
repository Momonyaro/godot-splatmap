@tool class_name DungeonMapResource extends Resource

@export var size: Vector2i = Vector2i(16, 16)
@export_file_path var tileset_ref: String = ""

@export_group("Map Data")
@export var cells: Array[DungeonCellResource] = []

@export_group("Events")
@export var events: Array[DungeonMapEvent] = []


#region Init/Setup

func init_grid(new_size: Vector2i) -> void:
	assert(new_size.x > 0 and new_size.y, "Dungeon map size must be positive!")
	
	size = new_size
	cells.clear()
	events.clear()
	
	for i in range(size.x * size.y):
		cells.push_back(DungeonCellResource.new())

#endregion
#region Bounds

func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 && pos.y >= 0 && pos.x < size.x && pos.y < size.y

#endregion
#region Cells

func get_cell(pos: Vector2i) -> DungeonCellResource:
	if not is_valid_position(pos):
		return null
	
	var index := pos.y * size.x + pos.x
	return cells[index]


func set_cell(pos: Vector2i, cell: DungeonCellResource) -> void:
	if not is_valid_position(pos):
		return
	
	var index := pos.y * size.x + pos.x
	cells[index] = cell


func get_reachable_cells(start: Vector2i, max_distance: int = 4) -> Array[Vector2i]:
	var to_return: Array[Vector2i] = []
	
	if not is_valid_position(start):
		return to_return
	if get_cell(start) == null:
		return to_return
	
	var queue: Array[Vector2i] = [ start ]
	var distances: Dictionary = { start: 0 }
	
	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		var current_distance: int = distances[current]
		to_return.push_back(current)
		
		if current_distance >= max_distance:
			continue
		
		for direction in 4:
			var neighbor := current + DungeonDirection.get_vector(direction)
			if not is_valid_position(neighbor):
				continue
			if distances.has(neighbor):
				continue
			
			var edge := get_edge(current, direction)
			if edge != null and edge.type != DungeonEdgeResource.Type.NONE:
				continue
			
			distances[neighbor] = current_distance + 1
			queue.push_back(neighbor)
	return to_return

#endregion
#region Edges

func get_edge(pos: Vector2i, dir: DungeonDirection.Facing) -> DungeonEdgeResource:
	if not is_valid_position(pos):
		return null
	
	var cell := get_cell(pos)
	if cell == null:
		return null
	
	return cell.get_edge(dir)


func set_edge(pos: Vector2i, dir: DungeonDirection.Facing, edge: DungeonEdgeResource) -> void:
	if not is_valid_position(pos):
		return
	
	var cell := get_cell(pos)
	if cell == null:
		return
	
	cell.set_edge(dir, edge)

#endregion
#region Events

func get_events_at(pos: Vector2i, facing: DungeonDirection.Facing) -> Array[DungeonMapEvent]:
	var result: Array[DungeonMapEvent] = []
	if not is_valid_position(pos):
		return result
	
	for dungeon_event in events:
		if dungeon_event == null:
			continue
		if dungeon_event.position != pos:
			continue
		if dungeon_event.facing != facing:
			continue
		result.push_back(dungeon_event)
	return result


func find_cell_with_tag(tag: StringName) -> DungeonCellResource:
	for cell in cells:
		if cell.has_tag(tag):
			return cell
	return null


func find_pos_with_tag(tag: StringName) -> Vector2:
	for y in size.y:
		for x in size.x:
			if get_cell(Vector2i(x, y)).has_tag(tag):
				return Vector2(x, y)
	return Vector2(-1, -1)

#endregion
#region Validation

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	
	if size.x <= 0 or size.y <= 0:
		errors.push_back("Map size must be positive.")
		return errors
	
	var expected_cells := size.x * size.y
	
	if cells.size() != expected_cells:
		errors.push_back("Invalid cell count: expected %d, got %d." % [expected_cells, cells.size()])
	
	for i in cells.size():
		if cells[i] == null:
			errors.append("Cell at index %d is null." % i)
	
	for i in events.size():
		var dungeon_event := events[i]
		
		if dungeon_event == null:
			errors.append("Event at index %d is null." % i)
			continue
		
		if not is_valid_position(dungeon_event.position):
			errors.append("Event at index %d has an invalid position." % i)
		if dungeon_event.event_id.is_empty():
			errors.append("Event at index %d has an empty event ID." % i)
	
	return errors


func is_valid() -> bool:
	return validate().is_empty()

#endregion
