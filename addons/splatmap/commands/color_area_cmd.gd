class_name SplatColorAreaCmd extends SplatCmd

@export var dst_pos: Vector2i
@export var size: Vector2i
@export var color: Color
@export var grid_aligned := true


func _init(color: Color, dst_pos: Vector2i, size: Vector2i, layer: int = 0, grid_aligned: bool = true) -> void:
	self.color = color
	self.dst_pos = dst_pos
	self.size = size
	self.layer = layer
	self.grid_aligned = grid_aligned

func execute(target: Image, ctx):
	if grid_aligned:
		dst_pos *= ctx.vram.CELL_SIZE
		size *= ctx.vram.CELL_SIZE
	target.fill_rect(Rect2i(dst_pos, size), color)
