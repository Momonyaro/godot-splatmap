class_name DungeonDirection extends RefCounted


enum Facing {
	NORTH,
	EAST,
	SOUTH,
	WEST
}


const VECTORS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT
]


static func get_vector(direction: Facing) -> Vector2i:
	if direction < Facing.NORTH or direction > Facing.WEST:
		return Vector2i.ZERO

	return VECTORS[direction]


static func rotate(direction: Facing, amount: int) -> Facing:
	return posmod(direction + amount, 4) as Facing


static func opposite(direction: Facing) -> Facing:
	return rotate(direction, 2)
