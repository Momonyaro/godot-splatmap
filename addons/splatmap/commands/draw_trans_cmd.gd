class_name SplatDrawTransparentCmd extends SplatCmd

@export var sample_pos: Vector2i
@export var dst_pos: Vector2i
@export var grid_aligned := true
@export var flip_x := false
@export var flip_y := false

func _init(sample_pos: Vector2i, dst_pos: Vector2i, layer: int = 0, grid_aligned: bool = true, flip_x: bool = false, flip_y: bool = false) -> void:
	self.sample_pos = sample_pos
	self.dst_pos = dst_pos
	self.layer = layer
	self.grid_aligned = grid_aligned
	self.flip_x = flip_x
	self.flip_y = flip_y

func execute(target: Image, ctx):
	var dst = dst_pos
	if grid_aligned:
		dst = dst_pos * ctx.vram.CELL_SIZE
	ctx.vram.sample_cell_transparent(sample_pos.x, sample_pos.y, target, dst, flip_x, flip_y)
