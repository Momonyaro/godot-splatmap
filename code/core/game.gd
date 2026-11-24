extends Node

signal state_updated(key: String, value: Variant)

## [game.gd]
## This is the core, this holds the main states.

var _state := {}


func set_state(key: String, value: Variant, send_event: bool = true) -> void:
	#print("setting state for %s - %s" % [key, value])
	var path := _build_path(key)
	if path.size() > 0:
		var last_box := _state
		for box: String in path[0]:
			if not last_box.has(box):
				last_box[box] = {}
			last_box = last_box[box]
		last_box[path[1]] = value
	if send_event:
		state_updated.emit(key, value)


func bulk_set_state(group_key: String, keys: Array, values: Array) -> void:
	for i in keys.size():
		set_state(keys[i], values[i], false)
	state_updated.emit(group_key, null)


func clear_state(key: String) -> void:
	var path := _build_path(key)
	if path.size() > 0:
		var last_box := _state
		for box: String in path[0]:
			if not last_box.has(box):
				return # Path doesn't exist, nothing to delete!
			last_box = last_box[box]
		last_box.erase(path[1])
	state_updated.emit(key, null)


func get_state(key: String, default: Variant = null) -> Variant:
	var path := _build_path(key)
	if path.size() > 0:
		var last_box := _state
		for box: String in path[0]:
			if not last_box.has(box):
				return default # Path doesn't exist, nothing to get!
			last_box = last_box[box]
		return last_box.get(path[1], default)
	return default


func _build_path(input: String) -> Array:
	var split := input.split('.')
	
	if split.size() > 1:
		return [split.slice(0, split.size() - 1), split[-1]]
	elif split.size() == 1:
		return [[], split[0]]
	return []
