@tool class_name BakeResultResource extends Resource

@export_group("Source")
@export var source_image_path: String
@export var regions: Array[Rect2i] = []

@export_group("Atlas")
@export var atlas_path: String = ""
@export var tile_size: Vector2i = Vector2i(8, 8)
@export var atlas_size: Vector2i
@export var atlas_columns: int
@export var atlas_rows: int

@export_group("Statistics")
@export var input_tile_count: int
@export var unique_tile_count: int
@export var duplicate_tile_count: int
@export var empty_tile_count: int

@export_group("Mappings")
@export var mappings: Array[BakeTileMapping] = []


## Runtime-only data used between processing and packing.
## Not exported, so it won't be serialized into the .tres.
var unique_tiles: Array[PackedByteArray] = []
var packed_image: Image
var error_message: String = ""
var success: bool:
	get:
		return error_message.is_empty()
