extends RefCounted

const CELL_SIZE := 8
const MEM_WIDTH := 32
const MEM_HEIGHT := 32

var initialized := false 

var _data: Image = null

func _init() -> void:
	var img_width := MEM_WIDTH * CELL_SIZE
	var img_height := MEM_HEIGHT * CELL_SIZE
	_data = Image.create_empty(img_width, img_height, false, Image.FORMAT_RGBA8)
	initialized = true


func write_img(x: int, y: int, src: Image, src_rect: Rect2i) -> bool:
	if src == null or (src_rect.get_area() % CELL_SIZE != 0):
		return false
	
	var dst := Vector2i(x * CELL_SIZE, y * CELL_SIZE)
	_data.blit_rect(src, src_rect, dst)
	return true


func sample_cell(x: int, y: int, target: Image, dst: Vector2i, flip_x: bool = false, flip_y: bool = false) -> void:
	var src_rect := Rect2i(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
	target.blit_rect_complex(_data, src_rect, dst, flip_x, flip_y)


func sample_cellv(pos: Vector2i, target: Image, dst: Vector2i, flip_x: bool = false, flip_y: bool = false) -> void:
	sample_cell(pos.x, pos.y, target, dst, flip_x, flip_y)


func sample_cell_transparent(x: int, y: int, target: Image, dst: Vector2i, flip_x: bool = false, flip_y: bool = false) -> void:
	var src_rect := Rect2i(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
	target.blend_rect_complex(_data, src_rect, dst, flip_x, flip_y)


func sample_cell_transparentv(pos: Vector2i, target: Image, dst: Vector2i, flip_x: bool = false, flip_y: bool = false) -> void:
	sample_cell_transparent(pos.x, pos.y, target, dst, flip_x, flip_y)
