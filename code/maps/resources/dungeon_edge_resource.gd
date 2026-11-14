class_name DungeonEdgeResource extends Resource

enum Type {
	NONE,
	WALL,
	DOOR
}

@export var type := Type.NONE
@export var definition_id := -1
@export var can_traverse: bool = false

func is_blocking() -> bool:
	match type:
		Type.WALL: return true
		Type.DOOR: return not can_traverse
		_: return false
