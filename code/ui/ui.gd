extends Node

## [ui.gd]
## Container for other UI components, managing states.

var _state: Dictionary = {
	"ui.layer": 3,
	"ui.frame.visible": true,
	"ui.cmdbar.visible": true
}

func _ready() -> void:
	for item in get_children():
		item.setup(self)
	_percolate_state()


func set_state(key: String, value: Variant) -> void:
	_state[key] = value
	_percolate_state()


func get_state(key: String, default: Variant = null) -> Variant:
	return _state.get(key, default)


func _percolate_state() -> void:
	for item in get_children():
		item.update()
