extends Node

## [ui.gd]
## Container for other UI components, managing states.

const TO_LOAD: Dictionary = {
	"res://art/ui/ui_spritesheet.png": Vector2i(0, 0),
	"res://art/font/_font_sheet_alt.png": Vector2i(0, 8)
} 

var _initial_ui_state: Dictionary = {
	"ui.layer": 2,
	"ui.frame.visible": true,
	"ui.cmdbar.visible": true,
	"ui.party.visible": true,
	"ui.party.in_battle": true,
	"ui.party.items": [
		{ "name": "Momonyaro", "hp": Vector2i(999, 999), "ap": Vector2i(100, 200), "active": true }, 
		{ "name": "Splatmap", "hp": Vector2i(999, 999), "ap": Vector2i(0, 0), "active": false }
	]
}

func _ready() -> void:
	for key in TO_LOAD.keys():
		var res := load(key)
		Splatmap.write_to_vram(res, TO_LOAD[key])
	
	var bulk_keys := []
	var bulk_values := []
	for key in _initial_ui_state.keys():
		bulk_keys.push_back(key)
		bulk_values.push_back(_initial_ui_state[key])
	
	owner.bulk_set_state("ui", bulk_keys, bulk_values)
