@tool extends EditorPlugin

var _bake_context_menu: EditorContextMenuPlugin

func _enable_plugin() -> void:
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	_bake_context_menu = preload("bake_context_menu.gd").new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, _bake_context_menu)
	pass


func _exit_tree() -> void:
	if _bake_context_menu != null:
		remove_context_menu_plugin(_bake_context_menu)
		_bake_context_menu = null
