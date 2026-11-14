@tool class_name DungeonMapCanvas extends Control


signal cell_clicked(position: Vector2i)

const GRID_COLOR := Color(0.25, 0.29, 0.35)
const CELL_COLOR := Color(0.12, 0.14, 0.18)
const SELECTED_COLOR := Color(0.20, 0.30, 0.43)
const WALL_COLOR := Color(0.85, 0.85, 0.88)
const DOOR_COLOR := Color(0.85, 0.65, 0.30)
const TRAVERSABLE_DOOR_COLOR := Color(0.35, 0.85, 0.55)
const SELECTED_EDGE_COLOR := Color(0.35, 0.65, 1.0)
const TAGGED_CELL_COLOR := Color(0.95, 0.75, 0.3)

var map: DungeonMapResource
var selected_cell := Vector2i(-1, -1)
var selected_direction := DungeonDirection.Facing.NORTH

var _cell_size := 32.0
var _grid_origin := Vector2.ZERO


func set_map(map: DungeonMapResource) -> void:
	self.map = map
	queue_redraw()


func set_selected_cell(pos: Vector2i) -> void:
	selected_cell = pos
	queue_redraw()


func set_selected_direction(dir: DungeonDirection.Facing) -> void:
	selected_direction = dir
	queue_redraw()


func _draw() -> void:
	if map == null:
		return
	
	if map.size.x <= 0 or map.size.y <= 0:
		return
	
	if map.cells.size() != map.size.x * map.size.y:
		return
	
	_calculate_grid_transform()
	_draw_cells()
	_draw_grid()
	_draw_selected_edge()
	_draw_edges()


func _calculate_grid_transform() -> void:
	var padding := 32.0
	var available := size - Vector2.ONE * padding * 2.0
	
	_cell_size = minf(available.x / map.size.x, available.y / map.size.y)
	_cell_size = maxf(_cell_size, 4.0)
	var grid_size := Vector2(map.size.x * _cell_size, map.size.y * _cell_size)
	_grid_origin = (size - grid_size) * 0.5


func _get_cell_rect(pos: Vector2i) -> Rect2:
	return Rect2(_grid_origin + Vector2(pos) * _cell_size, Vector2.ONE * _cell_size)


func _draw_cells() -> void:
	for y in map.size.y:
		for x in map.size.x:
			var pos := Vector2i(x, y)
			var rect := _get_cell_rect(pos)
			
			var color := CELL_COLOR
			if pos == selected_cell:
				color = SELECTED_COLOR
			
			draw_rect(rect, color, true)
			
			var cell := map.get_cell(pos)
			if cell != null and not cell.tags.is_empty():
				draw_circle(rect.position + Vector2(7, 7), 2.5, TAGGED_CELL_COLOR)


func _draw_grid() -> void:
	var grid_width := map.size.x * _cell_size
	var grid_height := map.size.y * _cell_size
	
	for x in range(map.size.x + 1):
		var px := _grid_origin.x + x * _cell_size
		draw_line(
			Vector2(px, _grid_origin.y),
			Vector2(px, _grid_origin.y + grid_height),
			GRID_COLOR, 1.0
		)
	
	for y in range(map.size.y + 1):
		var py := _grid_origin.y + y * _cell_size
		draw_line(
			Vector2(_grid_origin.x, py),
			Vector2(_grid_origin.x + grid_width, py),
			GRID_COLOR, 1.0
		)


func _draw_selected_edge() -> void:
	if not map.is_valid_position(selected_cell):
		return
	
	var rect := _get_cell_rect(selected_cell)
	_draw_edge(rect, selected_direction, 0, false, true)


func _draw_edges() -> void:
	for y in map.size.y:
		for x in map.size.x:
			var pos := Vector2i(x, y)
			var cell := map.get_cell(pos)
			
			if cell == null:
				continue
			
			var rect := _get_cell_rect(pos)
			for dir in 4:
				var edge := cell.get_edge(dir)
				if edge == null:
					continue
					
				_draw_edge(rect, dir, edge.type, edge.can_traverse, false)


func _draw_edge(rect: Rect2, direction: int, type: DungeonEdgeResource.Type, traverse: bool, selected: bool) -> void:
	if type == DungeonEdgeResource.Type.NONE and not selected:
		return
	
	var inset := minf(3.0, _cell_size * 0.1)
	var start := Vector2.ZERO
	var end := Vector2.ZERO
	
	match direction:
		DungeonDirection.Facing.NORTH:
			start = rect.position + Vector2(inset, inset)
			end = rect.position + Vector2(_cell_size - inset, inset)
		DungeonDirection.Facing.SOUTH:
			start = rect.position + Vector2(inset, _cell_size - inset)
			end = rect.position + Vector2(_cell_size - inset, _cell_size - inset)
		DungeonDirection.Facing.WEST:
			start = rect.position + Vector2(inset, inset)
			end = rect.position + Vector2(inset, _cell_size - inset)
		DungeonDirection.Facing.EAST:
			start = rect.position + Vector2(_cell_size - inset, inset)
			end = rect.position + Vector2(_cell_size - inset, _cell_size - inset)
	
	var color := WALL_COLOR
	var width := maxf(2.0, _cell_size * 0.12)
	if selected:
		color = SELECTED_EDGE_COLOR
		width = maxf(2.0, _cell_size * 0.08)
	elif type == DungeonEdgeResource.Type.DOOR:
		color = ( TRAVERSABLE_DOOR_COLOR if traverse else DOOR_COLOR )
	
	draw_line(start, end, color, width)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var cell := _get_cell_at(event.position)
			if cell.x >= 0:
				cell_clicked.emit(cell)
				accept_event()


func _get_cell_at(local_position: Vector2) -> Vector2i:
	if map == null:
		return Vector2i(-1, -1)
	
	var relative := local_position - _grid_origin
	if relative.x < 0 or relative.y < 0:
		return Vector2i(-1, -1)
	
	var cell := Vector2i(floori(relative.x / _cell_size), floori(relative.y / _cell_size))
	if not map.is_valid_position(cell):
		return Vector2i(-1, -1)
	
	return cell
