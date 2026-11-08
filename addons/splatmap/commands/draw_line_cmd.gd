class_name SplatDrawLineCmd extends SplatCmd

@export var sample_pos: Vector2i
@export var dst_y: int
@export var grid_aligned := true

func _init(sample_pos: Vector2i, dst_y: int, layer: int = 0, grid_aligned: bool = true) -> void:
	self.sample_pos = sample_pos
	self.dst_y = dst_y
	self.layer = layer
	self.grid_aligned = grid_aligned

func execute(target: Image, ctx):
	var dst := dst_y
	if grid_aligned:
		dst = dst_y * ctx.vram.CELL_SIZE
	var line := Image.create_empty(ctx.vram.CELL_SIZE, ctx.vram.CELL_SIZE, false, Image.FORMAT_RGBA8)
	var w: int = ctx.screen_w
	
	ctx.vram.sample_cell(sample_pos.x, sample_pos.y, line, Vector2i())
	line.resize(w, ctx.vram.CELL_SIZE, Image.INTERPOLATE_NEAREST)
	target.blit_rect(line, Rect2i(Vector2i(), line.get_size()), Vector2i(0, dst))
