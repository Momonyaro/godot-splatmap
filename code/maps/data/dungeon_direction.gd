class_name DungeonDirection extends RefCounted


enum Facing {
	NORTH,
	EAST,
	SOUTH,
	WEST
}

enum RelativeFacing {
	LEFT, FLAT, RIGHT, BEHIND
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


static func get_relative(d1: Facing, d2: Facing) -> RelativeFacing:
	if d1 == d2:
		return RelativeFacing.FLAT
	
	match d1:
		Facing.NORTH:
			match d2:
				Facing.EAST: return RelativeFacing.RIGHT
				Facing.WEST: return RelativeFacing.LEFT
				Facing.SOUTH: return RelativeFacing.BEHIND
		Facing.WEST:
			match d2:
				Facing.NORTH: return RelativeFacing.RIGHT
				Facing.EAST: return RelativeFacing.BEHIND
				Facing.SOUTH: return RelativeFacing.LEFT
		Facing.EAST:
			match d2:
				Facing.NORTH: return RelativeFacing.LEFT
				Facing.WEST: return RelativeFacing.BEHIND
				Facing.SOUTH: return RelativeFacing.RIGHT
		Facing.SOUTH:
			match d2:
				Facing.NORTH: return RelativeFacing.BEHIND
				Facing.WEST: return RelativeFacing.RIGHT
				Facing.EAST: return RelativeFacing.LEFT
	return RelativeFacing.BEHIND
