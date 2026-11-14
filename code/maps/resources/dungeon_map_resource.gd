@tool class_name DungeonMapResource extends Resource

@export var size: Vector2i = Vector2i(16, 16)

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
