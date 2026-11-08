extends Node

const Vram = preload("vram.gd")
const Layer = preload("layer.gd")

var clear_color := Color.BLACK

var _vram: Vram
var _render_target: ImageTexture
var _canvas_size := Vector2i(64, 64)
var _canvas: Image
var _layers: Array[Layer]

var _render_context := {}


func _enter_tree() -> void:
	_vram = Vram.new()
	_render_target = ImageTexture.new()
	if ProjectSettings.has_setting("splatmap/canvas_size"):
		_canvas_size = ProjectSettings.get_setting("splatmap/canvas_size")
	_canvas = Image.create_empty(_canvas_size.x, _canvas_size.y, false, Image.FORMAT_RGBA8)
	
	_render_context =  {
		'vram': _vram,
		'screen_w': _canvas_size.x,
		'screen_h': _canvas_size.y
	}
	
	for i in 4:
		_layers.push_back(Layer.new(i, _canvas_size))


func _process(delta: float) -> void:
	_render_to_target(delta)


func get_render_target() -> Texture2D:
	return _render_target


func get_canvas_size() -> Vector2i:
	return _canvas_size


func add_immediate(cmd: SplatCmd):
	_layers[cmd.layer].add_immediate(cmd)


func register_draw(cmd: SplatCmd) -> int:
	return _layers[cmd.layer].add_command(cmd)


func unregister_draw(layer: int, id: int) -> bool:
	return _layers[layer].remove_command(id)


func set_layer_effect(layer: int, key: String, effect: SplatEffect) -> void:
	if effect == null:
		_layers[layer].effects.erase(key)
	_layers[layer].effects[key] = effect


func clear_layer_effects(layer: int) -> void:
	_layers[layer].effects.clear()


func set_draw_fast(layer: int, active: bool) -> void:
	_layers[layer].draw_fast = active


func _render_to_target(delta: float) -> void:
	_canvas.fill(clear_color)
	#_checkerboard()
	#_rand_noise(256)
	
	for i in _layers.size():
		var layer = _layers[i]
		layer.render(_render_context)
		layer.apply_effects(delta)
		
		if layer.has_commands():
			if layer.draw_fast || i == 0:
				_canvas.blit_rect(layer.image, Rect2i(Vector2i(), _canvas_size), Vector2i())
			else:
				_canvas.blend_rect(layer.image, Rect2i(Vector2i(), _canvas_size), Vector2i())
			layer.flush()
		
	_render_target.set_image(_canvas)


#region Debug Draw Patterns
func _rand_noise(pips: int) -> void:
	for pip in pips:
		var rand_pos := Vector2i(randi_range(0, _canvas_size.x - 1), randi_range(0, _canvas_size.y - 1))
		_canvas.set_pixelv(rand_pos, Color(randf(), randf(), randf()))


func _checkerboard() -> void:
	for y in _canvas_size.y:
		for x in _canvas_size.x:
			if (x + y) % 2:
				_canvas.set_pixel(x, y, Color(0.1, 0.1, 0.1))
#endregion
