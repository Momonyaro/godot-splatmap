@abstract class_name UIComponentBase extends Node

@warning_ignore("unused_private_class_variable")
var _ui: Node = null
@warning_ignore("unused_private_class_variable")
var _cmds := []

@abstract func setup(ui: Node) -> void
@abstract func update() -> void

func _register_draw(cmd: SplatCmd) -> void:
	_cmds.push_back(Splatmap.register_draw(cmd))
	pass
