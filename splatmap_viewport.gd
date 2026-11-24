extends TextureRect

@export var clear_color := Color.BLACK
@export var test_sky: Texture2D
@export var test_map: DungeonMapResource
@export var debug_vram_view: TextureRect

var _last_parent_size := Vector2()


func _enter_tree() -> void:
	visible = false
	var shader_map: ShaderMaterial = material
	shader_map.set_shader_parameter("tex", Splatmap.get_render_target())


func _ready() -> void:
	_resize.call_deferred()
	visible = true


func _process(_delta: float) -> void:
	if debug_vram_view:
		debug_vram_view.texture = ImageTexture.create_from_image(Splatmap._vram._data)
	
	var parent := get_parent_control()
	if parent and parent.size != _last_parent_size:
		_resize()


func _resize() -> void:
	_resize_pixel_perfect()
	_place_at_center()


func _resize_pixel_perfect() -> void:
	var parent := get_parent_control()
	var parent_size := parent.size
	
	var splatmap_size: Vector2i = ProjectSettings.get_setting("splatmap/canvas_size")
	var ratio_x := floori(parent_size.x / splatmap_size.x)
	var ratio_y := floori(parent_size.y / splatmap_size.y)
	var lowest_common := maxi(mini(ratio_x, ratio_y), 1)
	size = splatmap_size * lowest_common
	_last_parent_size = parent_size


func _place_at_center() -> void:
	var parent := get_parent_control()
	var parent_size := parent.size
	
	var x_pos := roundi((parent_size.x - size.x) / 2.0)
	var y_pos := roundi((parent_size.y - size.y) / 2.0)
	position = Vector2i(x_pos, y_pos)
