class_name SplatDrawComplexCmd extends SplatCmd

@export var samples: Array
@export var dst_pos: Vector2i
@export var grid_aligned := true
@export var grid_align_samples := true

# DATA STRUCTURE
# [SAMPLE_POS, DST_POS, FLIP_X, FLIP_Y, IS_TRANSPARENT]

func _init(sample_arr: Array, dst_pos: Vector2i, layer: int = 0, grid_aligned: bool = true, grid_align_samples: bool = true) -> void:
	self.samples = sample_arr
	self.dst_pos = dst_pos
	self.layer = layer
	self.grid_aligned = grid_aligned
	self.grid_align_samples = grid_align_samples


func execute(target: Image, ctx):
	var dst = dst_pos
	if grid_aligned:
		dst = dst_pos * ctx.vram.CELL_SIZE
	
	for sample in samples:
		var s_dst = sample[1]
		if grid_align_samples:
			s_dst = sample[1] * ctx.vram.CELL_SIZE
		
		if sample[4]:
			ctx.vram.sample_cell_transparentv(sample[0], target, dst + s_dst, sample[2], sample[3])
		else:
			ctx.vram.sample_cellv(sample[0], target, dst + s_dst, sample[2], sample[3])
