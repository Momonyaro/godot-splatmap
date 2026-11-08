@tool class_name BakeRegionResource extends Resource

@export var source_image: Texture2D

@export_group("Bake Settings")
@export var tile_size: Vector2i = Vector2i(8, 8)
@export_range(0, 128) var max_columns: int = 16

@export_group("Regions")
@export var regions: Array[Rect2i] = []
