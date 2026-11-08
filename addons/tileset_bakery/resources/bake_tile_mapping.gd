@tool class_name BakeTileMapping extends Resource


@export var region_index: int = -1
@export var tile_position: Vector2i

## Position of the tile in the original source image.
@export var source_rect: Rect2i

## Index of the unique tile in the compressed atlas.
## -1 means the tile was completely transparent.
@export var tile_index: int = -1

## Position in the compressed atlas.
## (-1, -1) means no tile was generated.
@export var atlas_position: Vector2i = Vector2i(-1, -1)
@export var has_transparency: bool = false


var is_empty: bool:
	get:
		return tile_index < 0
