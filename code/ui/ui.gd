extends Node

## [ui.gd]
## Container for other UI components, managing states.

const TO_LOAD: Dictionary = {
	"res://art/ui/ui_spritesheet.png": Vector2i(0, 0),
	"res://art/font/_font_sheet_alt.png": Vector2i(0, 8)
} 

var _state: Dictionary = {
	"layer": 2,
	"frame.visible": true,
	"cmdbar.visible": true,
	"cmdbar.text": "LOCATION                          1F - SOUTH",
	"party.visible": true,
	"party.in_battle": false,
	"party.items": [{ "name": "Momonyaro", "hp": Vector2i(999, 999), "ap": Vector2i(100, 200), "active": true }, { "name": "Splatmap", "hp": Vector2i(999, 999), "ap": Vector2i(0, 0), "active": false }]
}

func _ready() -> void:
	for key in TO_LOAD.keys():
		var res := load(key)
		Splatmap.write_to_vram(res, TO_LOAD[key])
	
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
