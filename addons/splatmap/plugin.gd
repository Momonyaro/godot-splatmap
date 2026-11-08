@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	add_autoload_singleton("Splatmap", "res://addons/splatmap/core/autoload.gd")
	
	ProjectSettings.set_setting("splatmap/canvas_size", Vector2i(256, 240))


func _disable_plugin() -> void:
	# Remove autoloads here.
	remove_autoload_singleton("Splatmap")
	
	if ProjectSettings.has_setting("splatmap/canvas_size"):
		ProjectSettings.clear("splatmap/canvas_size")


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
