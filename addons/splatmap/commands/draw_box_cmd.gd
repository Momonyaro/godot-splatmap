class_name SplatDrawBoxCmd extends SplatCmd

@export var parts: Dictionary[String, Vector2i] = {
	"tl": Vector2i(), "tc": Vector2i(), "tr": Vector2i(),
	"ml": Vector2i(), "mc": Vector2i(), "mr": Vector2i(),
	"bl": Vector2i(), "bc": Vector2i(), "br": Vector2i()
}
@export var dst_pos: Vector2i
@export var size: Vector2i
@export var stretch := false
@export var grid_aligned := true

func _init(parts: Dictionary[String, Vector2i], dst_pos: Vector2i, size: Vector2i, stretch: bool, layer: int = 0, grid_aligned: bool = true) -> void:
	self.parts = parts.duplicate()
	self.dst_pos = dst_pos
	self.size = Vector2i(maxi(size.x - 1, 0), maxi(size.y - 1, 0)) if grid_aligned else size
	self.stretch = stretch
	self.layer = layer
	self.grid_aligned = grid_aligned
	

func execute(target: Image, ctx):
	var scaled_size = size
	var dst = dst_pos
	if grid_aligned:
		dst = dst_pos * ctx.vram.CELL_SIZE
		scaled_size = size * ctx.vram.CELL_SIZE
	
	ctx.vram.sample_cellv(parts['tl'], target, dst)
	ctx.vram.sample_cellv(parts['tr'], target, dst + Vector2i(scaled_size.x, 0))
	ctx.vram.sample_cellv(parts['bl'], target, dst + Vector2i(0, scaled_size.y))
	ctx.vram.sample_cellv(parts['br'], target, dst + Vector2i(scaled_size.x, scaled_size.y))
	
	if not stretch:
		for x in range(1, size.x, 1):
			ctx.vram.sample_cellv(parts['tc'], target, dst + Vector2i(x * ctx.vram.CELL_SIZE, 0))
			ctx.vram.sample_cellv(parts['bc'], target, dst + Vector2i(x * ctx.vram.CELL_SIZE, scaled_size.y))
		for y in range(1, size.y, 1):
			ctx.vram.sample_cellv(parts['ml'], target, dst + Vector2i(0, y * ctx.vram.CELL_SIZE))
			ctx.vram.sample_cellv(parts['mr'], target, dst + Vector2i(scaled_size.x, y * ctx.vram.CELL_SIZE))
		for y in range(1, size.y, 1):
			for x in range(1, size.x, 1):
				ctx.vram.sample_cellv(parts['mc'], target, dst + Vector2i(x * ctx.vram.CELL_SIZE, y * ctx.vram.CELL_SIZE))
	else:
		if size.x > 1:
			var top_line := Image.create_empty(ctx.vram.CELL_SIZE, ctx.vram.CELL_SIZE, false, Image.FORMAT_RGBA8)
			ctx.vram.sample_cellv(parts['tc'], top_line, Vector2i())
			var bottom_line := Image.create_empty(ctx.vram.CELL_SIZE, ctx.vram.CELL_SIZE, false, Image.FORMAT_RGBA8)
			ctx.vram.sample_cellv(parts['bc'], bottom_line, Vector2i())
			
			top_line.resize(scaled_size.x - 2, ctx.vram.CELL_SIZE, Image.INTERPOLATE_NEAREST)
			bottom_line.resize(scaled_size.x - 2, ctx.vram.CELL_SIZE, Image.INTERPOLATE_NEAREST)
			target.blit_rect(top_line, Rect2i(Vector2i(), top_line.get_size()), dst + Vector2i(ctx.vram.CELL_SIZE, 0))
			target.blit_rect(bottom_line, Rect2i(Vector2i(), bottom_line.get_size()), dst + Vector2i(ctx.vram.CELL_SIZE, scaled_size.y))
		if size.y > 1:
			var left_line := Image.create_empty(ctx.vram.CELL_SIZE, ctx.vram.CELL_SIZE, false, Image.FORMAT_RGBA8)
			ctx.vram.sample_cellv(parts['ml'], left_line, Vector2i())
			var right_line := Image.create_empty(ctx.vram.CELL_SIZE, ctx.vram.CELL_SIZE, false, Image.FORMAT_RGBA8)
			ctx.vram.sample_cellv(parts['mr'], right_line, Vector2i())
			
			left_line.resize(ctx.vram.CELL_SIZE, scaled_size.y - 2, Image.INTERPOLATE_NEAREST)
			right_line.resize(ctx.vram.CELL_SIZE, scaled_size.y - 2, Image.INTERPOLATE_NEAREST)
			target.blit_rect(left_line, Rect2i(Vector2i(), left_line.get_size()), dst + Vector2i(0, ctx.vram.CELL_SIZE))
			target.blit_rect(right_line, Rect2i(Vector2i(), right_line.get_size()), dst + Vector2i(scaled_size.x, ctx.vram.CELL_SIZE))
		if size.x > 1 and size.y > 1:
			var center_area := Image.create_empty(ctx.vram.CELL_SIZE, ctx.vram.CELL_SIZE, false, Image.FORMAT_RGBA8)
			ctx.vram.sample_cellv(parts['mc'], center_area, Vector2i())
			
			center_area.resize(scaled_size.x - 2, scaled_size.y - 2, Image.INTERPOLATE_NEAREST)
			target.blit_rect(center_area, Rect2i(Vector2i(), center_area.get_size()), dst + Vector2i(ctx.vram.CELL_SIZE, ctx.vram.CELL_SIZE))
