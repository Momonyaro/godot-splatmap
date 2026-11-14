@tool class_name DungeonMapEditor extends VBoxContainer

enum Tool {
	SELECT,
	WALL,
	DOOR,
	ERASE
}

var _map: DungeonMapResource
var _undo_redo: EditorUndoRedoManager
var _canvas: DungeonMapCanvas
var _tool_option: OptionButton
var _direction_option: OptionButton
var _symmetric_check: CheckButton
var _traversable_check: CheckButton
var _selected_label: Label
var _tags_input: LineEdit
var _apply_tags_button: Button
var _save_button: Button
var _status_label: Label

var _selected_cell := Vector2i(-1, -1)
var _active_tool := Tool.SELECT
var _active_direction := DungeonDirection.Facing.NORTH


func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_interface()


func set_undo_redo(manager: EditorUndoRedoManager) -> void:
	_undo_redo = manager


func _build_interface() -> void:
	var toolbar := HBoxContainer.new()
	add_child(toolbar)
	
	_tool_option = OptionButton.new()
	_tool_option.add_item("Select", Tool.SELECT)
	_tool_option.add_item("Wall", Tool.WALL)
	_tool_option.add_item("Door", Tool.DOOR)
	_tool_option.add_item("Erase", Tool.ERASE)
	_tool_option.item_selected.connect(_on_tool_selected)
	toolbar.add_child(_tool_option)
	
	var direction_label := Label.new()
	direction_label.text = "Direction:"
	toolbar.add_child(direction_label)
	
	_direction_option = OptionButton.new()
	_direction_option.add_item("North", DungeonDirection.Facing.NORTH)
	_direction_option.add_item("East", DungeonDirection.Facing.EAST)
	_direction_option.add_item("South", DungeonDirection.Facing.SOUTH)
	_direction_option.add_item("West", DungeonDirection.Facing.WEST)
	_direction_option.item_selected.connect(_on_direction_selected)
	toolbar.add_child(_direction_option)
	
	_symmetric_check = CheckButton.new()
	_symmetric_check.text = "Symmetric"
	_symmetric_check.button_pressed = true
	toolbar.add_child(_symmetric_check)
	
	_traversable_check = CheckButton.new()
	_traversable_check.text = "Can Traverse"
	_traversable_check.visible = false
	toolbar.add_child(_traversable_check)
	
	var save_spacer := Control.new()
	save_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(save_spacer)
	
	_save_button = Button.new()
	_save_button.text = "Save Map"
	_save_button.pressed.connect(_save_map)
	toolbar.add_child(_save_button)
	
	# Cell properties toolbar
	var cell_toolbar := HBoxContainer.new()
	add_child(cell_toolbar)
	
	_selected_label = Label.new()
	_selected_label.text = "No cell selected..."
	cell_toolbar.add_child(_selected_label)
	
	var tags_label := Label.new()
	tags_label.text = "Tags:"
	cell_toolbar.add_child(tags_label)
	
	_tags_input = LineEdit.new()
	_tags_input.placeholder_text = "poison, dark, ..."
	_tags_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tags_input.editable = false
	_tags_input.text_submitted.connect(_on_tags_submitted)
	cell_toolbar.add_child(_tags_input)
	
	_apply_tags_button = Button.new()
	_apply_tags_button.text = "Apply"
	_apply_tags_button.disabled = true
	_apply_tags_button.pressed.connect(_apply_tags)
	cell_toolbar.add_child(_apply_tags_button)
	
	# Map Canvas
	_canvas = DungeonMapCanvas.new()
	_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_canvas.cell_clicked.connect(_on_cell_clicked)
	add_child(_canvas)
	
	# Status Bar
	_status_label = Label.new()
	_status_label.text = "No map loaded"
	add_child(_status_label)
	_update_selection_interface()


func edit_map(value: DungeonMapResource) -> void:
	if _map != null:
		if _map.changed.is_connected(_on_map_changed):
			_map.changed.disconnect(_on_map_changed)
	_map = value
	_selected_cell = Vector2i(-1, -1)
	if !_map.is_valid():
		_map.init_grid(_map.size)
	
	if _map != null:
		_map.changed.connect(_on_map_changed)
	
	_canvas.set_map(_map)
	_update_selection_interface()
	_update_save_button()
	
	if _map != null:
		_status_label.text = "%s  (%d x %d)" % [_map.resource_path.get_file(), _map.size.x, _map.size.y]
	else:
		_status_label.text = "No map loaded"


func _on_map_changed() -> void:
	_canvas.queue_redraw()
	_update_save_button()


func _update_save_button() -> void:
	_save_button.disabled = _map == null or _map.resource_path.is_empty()


func _on_tool_selected(index: int) -> void:
	_active_tool = _tool_option.get_item_id(index)
	_traversable_check.visible = _active_tool == Tool.DOOR


func _on_direction_selected(index: int) -> void:
	_active_direction = _direction_option.get_item_id(index)
	_canvas.set_selected_direction(_active_direction)


func _on_cell_clicked(pos: Vector2i) -> void:
	_selected_cell = pos
	_canvas.set_selected_cell(pos)
	if _active_tool != Tool.SELECT:
		_paint_edge(pos)
	
	_update_selection_interface()


func _update_selection_interface() -> void:
	if _map == null:
		_selected_label.text = "No cell selected"
		_tags_input.text = ""
		_tags_input.editable = false
		_apply_tags_button.disabled = true
		return
	if not _map.is_valid_position(_selected_cell):
		_selected_label.text = "No cell selected"
		_tags_input.text = ""
		_tags_input.editable = false
		_apply_tags_button.disabled = true
		return
	var cell := _map.get_cell(_selected_cell)
	if cell == null:
		_selected_label.text = "Invalid cell"
		_tags_input.text = ""
		_tags_input.editable = false
		_apply_tags_button.disabled = true
		return
	
	_selected_label.text = "Cell (%d, %d)" % [_selected_cell.x, _selected_cell.y]
	var tag_strings := PackedStringArray()
	for tag in cell.tags:
		tag_strings.push_back(String(tag))
	_tags_input.text = ", ".join(tag_strings)
	_tags_input.editable = true
	_apply_tags_button.disabled = false


func _paint_edge(pos: Vector2i) -> void:
	if _map == null:
		return
	
	var cell := _map.get_cell(pos)
	if cell == null:
		return
	
	var new_edge := DungeonEdgeResource.new()
	new_edge.definition_id = 0
	match _active_tool:
		Tool.WALL:
			new_edge.type = DungeonEdgeResource.Type.WALL
		Tool.DOOR:
			new_edge.type = DungeonEdgeResource.Type.DOOR
			new_edge.can_traverse = _traversable_check.button_pressed
		Tool.ERASE:
			new_edge = null
		_:
			return
	
	var changes: Array[Dictionary] = []
	_add_edge_change(changes, cell, _active_direction, new_edge)
	
	if _symmetric_check.button_pressed:
		var neighbor_position := pos + DungeonDirection.get_vector(_active_direction)
		if _map.is_valid_position(neighbor_position):
			var neighbor := _map.get_cell(neighbor_position)
			if neighbor != null:
				var opposite := DungeonDirection.opposite(_active_direction)
				var mirrored_edge: DungeonEdgeResource = null
				if new_edge != null:
					mirrored_edge = new_edge.duplicate()
					_add_edge_change(changes, neighbor, opposite, mirrored_edge)
	_commit_edge_changes(changes)


func _add_edge_change(
	changes: Array[Dictionary], cell: DungeonCellResource, 
	direction: DungeonDirection.Facing, new_edge: DungeonEdgeResource
) -> void:
	changes.append({
		"cell": cell,
		"direction": direction,
		"old": cell.get_edge(direction),
		"new": new_edge
	})


func _commit_edge_changes(changes: Array[Dictionary]) -> void:
	if changes.is_empty():
		return
	
	if _undo_redo == null:
		for change in changes:
			var cell: DungeonCellResource = change["cell"]
			cell.set_edge(change["direction"], change["new"])
		_map.emit_changed()
		return
	
	_undo_redo.create_action("Edit Dungeon Edges")
	for change in changes:
		var cell: DungeonCellResource = change["cell"]
		var direction: DungeonDirection.Facing = change["direction"]
		var old_edge: DungeonEdgeResource = change["old"]
		var new_edge: DungeonEdgeResource = change["new"]
		
		_undo_redo.add_do_method(cell, "set_edge", direction, new_edge)
		_undo_redo.add_undo_method(cell, "set_edge", direction, old_edge)
	_undo_redo.add_do_method(_map, "emit_changed")
	_undo_redo.add_undo_method(_map, "emit_changed")
	_undo_redo.commit_action()


func _on_tags_submitted(_text: String) -> void:
	_apply_tags()


func _apply_tags() -> void:
	if _map == null:
		return
	
	var cell := _map.get_cell(_selected_cell)
	if cell == null:
		return
	
	var new_tags: Array[StringName] = []
	for value in _tags_input.text.split(","):
		var tag := value.strip_edges()
		if tag.is_empty():
			continue
		var tag_name := StringName(tag)
		if not new_tags.has(tag_name):
			new_tags.push_back(tag_name)
	
	var old_tags: Array[StringName] = cell.tags.duplicate()
	if old_tags == new_tags:
		return
	
	if _undo_redo == null:
		cell.tags = new_tags
		_map.emit_changed()
		return
	
	_undo_redo.create_action("Edit Dungeon Cell Tags")
	_undo_redo.add_do_property(cell, "tags", new_tags)
	_undo_redo.add_undo_property(cell, "tags", old_tags)
	_undo_redo.add_do_method(_map, "emit_changed")
	_undo_redo.add_undo_method(_map, "emit_changed")
	_undo_redo.commit_action()
	_update_selection_interface()


func _save_map() -> void:
	if _map == null:
		return
	
	if _map.resource_path.is_empty():
		_status_label.text = "Map has no resource path."
		return
	
	var errors := _map.validate()
	
	if not errors.is_empty():
		for error in errors:
			push_error(error)
		
		_status_label.text = "Map validation failed."
		return
	
	var error := ResourceSaver.save(_map, _map.resource_path)
	if error != OK:
		_status_label.text = "Save failed %s" % error_string(error)
		push_error("Failed to save dungeon map: ", error_string(error))
		return
	
	_status_label.text = "Saved: %s" % _map.resource_path.get_file()
