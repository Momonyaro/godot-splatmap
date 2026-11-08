class_name SplatDrawComplexCmd extends SplatCmd

@export var samples: Array
@export var dst_pos: Vector2i
@export var grid_aligned := true


func _init(sample_arr: Array, dst_pos: Vector2i, layer: int = 0, grid_aligned: bool = true) -> void:
	self.samples = sample_arr
	self.dst_pos = dst_pos
	self.layer = layer
	self.grid_aligned = grid_aligned


func execute(target: Image, ctx):
	var dst = dst_pos
	if grid_aligned:
		dst = dst_pos * ctx.vram.CELL_SIZE
	
	for sample in samples:
		var s_dst = sample[1] * ctx.vram.CELL_SIZE
		if sample[4]:
			ctx.vram.sample_cell_transparentv(sample[0], target, dst + s_dst, sample[2], sample[3])
		else:
			ctx.vram.sample_cellv(sample[0], target, dst + s_dst, sample[2], sample[3])
