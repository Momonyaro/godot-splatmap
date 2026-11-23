@abstract class_name UIComponentBase extends Node

var _cmds := []
var _observed_states := []

@abstract func update() -> void


func _enter_tree() -> void:
	owner.state_updated.connect(_on_state_updated)

func _exit_tree() -> void:
	owner.state_updated.disconnect(_on_state_updated)

func _on_state_updated(key: String, _value: Variant) -> void:
	if key in _observed_states:
		update()

func _register_draw(cmd: SplatCmd) -> void:
	_cmds.push_back(Splatmap.register_draw(cmd))
	pass

func _get_game() -> Node:
	return owner
