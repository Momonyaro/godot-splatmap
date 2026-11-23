extends Node

## [world.gd]
## This what maintains state for the game world. Player position, turning and such.

var _initial_world_state: Dictionary = {
	"world.layer": 1,
	"world.player.facing": 2,
	"world.player.position": Vector2i(7, 1),
	"world.map": "res://test_map.tres"
}

func _ready() -> void:
	var bulk_keys := []
	var bulk_values := []
	for key in _initial_world_state.keys():
		bulk_keys.push_back(key)
		bulk_values.push_back(_initial_world_state[key])
	
	owner.bulk_set_state("world", bulk_keys, bulk_values)
