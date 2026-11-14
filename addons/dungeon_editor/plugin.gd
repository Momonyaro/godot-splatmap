@tool extends EditorPlugin

var _editor: Control

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	_editor = DungeonMapEditor.new()
	_editor.name = "DungeonMapEditor"
	
	_editor.set_undo_redo(
		get_editor_interface().get_editor_undo_redo()
	)
	
	get_editor_interface().get_editor_main_screen().add_child(_editor)
	_editor.hide()


func _exit_tree() -> void:
	if _editor != null:
		_editor.queue_free()


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "Dungeon Editor"


func _get_plugin_icon() -> Texture2D:
	return get_editor_interface().get_editor_theme().get_icon("Grid", "EditorIcons")


func _handles(object: Object) -> bool:
	return object is DungeonMapResource


func _edit(object: Object) -> void:
	if object is DungeonMapResource:
		_editor.edit_map(object)


func _make_visible(visible: bool) -> void:
	if _editor != null:
		_editor.visible = visible
