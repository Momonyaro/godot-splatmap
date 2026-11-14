@tool class_name DungeonCellResource extends Resource

@export var tags: Array[StringName] = []
@export_group("Edges")
@export var north_edge: DungeonEdgeResource
@export var east_edge: DungeonEdgeResource
@export var south_edge: DungeonEdgeResource
@export var west_edge: DungeonEdgeResource


func has_tag(tag: StringName) -> bool:
	return tags.has(tag)


func add_tag(tag: StringName) -> void:
	if not has_tag(tag):
		tags.push_back(tag)


func remove_tag(tag: StringName) -> void:
	tags.erase(tag)


func get_edge(dir: DungeonDirection.Facing) -> DungeonEdgeResource:
	match dir:
		DungeonDirection.Facing.NORTH: return north_edge
		DungeonDirection.Facing.EAST: return east_edge
		DungeonDirection.Facing.SOUTH: return south_edge
		DungeonDirection.Facing.WEST: return west_edge
		_: return null


func set_edge(dir: DungeonDirection.Facing, edge: DungeonEdgeResource) -> void:
	match dir:
		DungeonDirection.Facing.NORTH: north_edge = edge
		DungeonDirection.Facing.EAST: east_edge = edge
		DungeonDirection.Facing.SOUTH: south_edge = edge
		DungeonDirection.Facing.WEST: west_edge = edge
