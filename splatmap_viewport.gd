extends TextureRect

@export var clear_color := Color.BLACK
@export var test_cell: Texture2D
@export var test_cell2: Texture2D
@export var test_sky: Texture2D
@export var test_font: Texture2D
@export var hp_bar_color := Color.from_string("29cc49", Color.WHITE)
@export var ap_bar_color := Color.from_string("ff5b5b", Color.WHITE)
@export var debug_vram_view: TextureRect


func _enter_tree() -> void:
	visible = false
	var shader_map: ShaderMaterial = material
	shader_map.set_shader_parameter("tex", Splatmap.get_render_target())
	get_viewport().size_changed.connect(on_viewport_size_changed)


func _exit_tree() -> void:
	get_viewport().size_changed.disconnect(on_viewport_size_changed)


func _ready() -> void:
	Splatmap._vram.write_img(0, 0, test_cell.get_image(), Rect2i(Vector2i(), test_cell.get_size()))
	Splatmap._vram.write_img(3, 0, test_cell2.get_image(), Rect2i(Vector2i(), test_cell2.get_size()))
	Splatmap._vram.write_img(31, 0, test_sky.get_image(), Rect2i(Vector2i(), test_sky.get_size()))
	Splatmap._vram.write_img(0, 27, test_font.get_image(), Rect2i(Vector2i(), test_font.get_size()))
	
	if $Tileset != null:
		$Tileset.write_to_vram(Splatmap._vram, Vector2i(0, 3))
	
	if debug_vram_view:
		debug_vram_view.texture = ImageTexture.create_from_image(Splatmap._vram._data)
	Splatmap.clear_color = clear_color
	#Splatmap.set_layer_effect(0, "wavy", SplatWavyEffect.new())
	_resize.call_deferred()
	visible = true
	
	_draw_ui()
	for y in range(2, 16, 1):
		Splatmap.register_draw(SplatDrawLineCmd.new(Vector2i(31, y - 2), y, 0))
	
	Splatmap.register_draw(SplatDrawComplexCmd.new($Tileset.get_complex_wall("r_d3"), Vector2i(17, 8)))
	Splatmap.register_draw(SplatDrawComplexCmd.new($Tileset.get_complex_wall("l_d2"), Vector2i(12, 6)))
	Splatmap.register_draw(SplatDrawComplexCmd.new($Tileset.get_complex_wall("f_d2"), Vector2i(18, 8)))
	Splatmap.register_draw(SplatDrawComplexCmd.new($Tileset.get_complex_wall("r_d1"), Vector2i(20, 2)))
	Splatmap.register_draw(SplatDrawComplexCmd.new($Tileset.get_complex_wall("f_d1"), Vector2i(4, 6)))
	Splatmap.register_draw(SplatDrawComplexCmd.new($Tileset.get_complex_wall("l_d0"), Vector2i(0, 2)))
	Splatmap.register_draw(SplatDrawComplexCmd.new($Tileset.get_complex_wall("f_d0"), Vector2i(24, 2)))


func _process(_delta: float) -> void:
	pass


func _draw_ui():
	var panel_1: Dictionary[String, Vector2i] = {
		"tl": Vector2i(0, 0), "tc": Vector2i(1, 0), "tr": Vector2i(2, 0),
		"ml": Vector2i(0, 1), "mc": Vector2i(1, 1), "mr": Vector2i(2, 1),
		"bl": Vector2i(0, 2), "bc": Vector2i(1, 2), "br": Vector2i(2, 2)
	}
	
	for y in range(2, 16, 1):
		Splatmap.register_draw(SplatDrawCmd.new(panel_1.mr, Vector2i(0, y), 1))
		Splatmap.register_draw(SplatDrawCmd.new(panel_1.ml, Vector2i(31, y), 1))
	
	# TOP BAR
	Splatmap.register_draw(SplatDrawCmd.new(panel_1.mr, Vector2i(0, 0), 1))
	Splatmap.register_draw(SplatDrawCmd.new(panel_1.br, Vector2i(0, 1), 1))
	Splatmap.register_draw(SplatDrawBoxCmd.new(panel_1, Vector2i(1, -1), Vector2i(30, 3), true, 1))
	Splatmap.register_draw(SplatDrawCmd.new(panel_1.ml, Vector2i(31, 0), 1))
	Splatmap.register_draw(SplatDrawCmd.new(panel_1.bl, Vector2i(31, 1), 1))
	
	Splatmap.register_draw(SplatDrawBoxCmd.new(panel_1, Vector2i(-1, 17), Vector2i(2, 10), true, 1))
	Splatmap.register_draw(SplatDrawBoxCmd.new(panel_1, Vector2i(31, 17), Vector2i(2, 10), true, 1))
	
	# BOTTOM BAR
	Splatmap.register_draw(SplatDrawCmd.new(panel_1.tr, Vector2i(0, 27), 1))
	Splatmap.register_draw(SplatDrawBoxCmd.new(panel_1, Vector2i(1, 27), Vector2i(30, 2), true, 1))
	Splatmap.register_draw(SplatDrawCmd.new(panel_1.tl, Vector2i(31, 27), 1))
	
	
	Splatmap.register_draw(SplatDrawCmd.new(Vector2i(2, 0), Vector2i(0, 2), 1))
	Splatmap.register_draw(SplatDrawCmd.new(Vector2i(0, 0), Vector2i(31, 2), 1))
	Splatmap.register_draw(SplatDrawCmd.new(Vector2i(2, 2), Vector2i(0, 15), 1))
	Splatmap.register_draw(SplatDrawCmd.new(Vector2i(0, 2), Vector2i(31, 15), 1))
	Splatmap.register_draw(SplatDrawCmd.new(Vector2i(2, 0), Vector2i(0, 16), 1))
	Splatmap.register_draw(SplatDrawCmd.new(Vector2i(2, 2), Vector2i(0, 17), 1))
	Splatmap.register_draw(SplatDrawCmd.new(Vector2i(0, 0), Vector2i(31, 16), 1))
	Splatmap.register_draw(SplatDrawCmd.new(Vector2i(0, 2), Vector2i(31, 17), 1))
	
	# Playbar Rect
	Splatmap.register_draw(SplatDrawBoxCmd.new({
		"tl": Vector2i(3, 0), "tc": Vector2i(4, 0), "tr": Vector2i(5, 0),
		"ml": Vector2i(3, 1), "mc": Vector2i(4, 1), "mr": Vector2i(5, 1),
		"bl": Vector2i(3, 2), "bc": Vector2i(4, 2), "br": Vector2i(5, 2)
	}, Vector2i(1, 16), Vector2i(30, 2), true, 1))
	
	var cell_size := Splatmap.Vram.CELL_SIZE
	var block_spacing := floori(7.5 * cell_size)
	var portrait_h := floori(3.5 * cell_size)
	var block_x := cell_size
	var block_y := 18 * cell_size
	var char_y := 0
	
	for i in 4:
		_draw_party_box(panel_1, block_x + (i * block_spacing), block_y, portrait_h, char_y)


func _draw_party_box(panel_1, block_x, block_y, portrait_h, char_y) -> void:
	var char_name_start := Vector2i(block_x + 4, block_y + portrait_h + 7)
	var cell_size := Splatmap.Vram.CELL_SIZE
	var block_w := floori(6.5 * cell_size)
	var block_h := 8 * cell_size
	var portrait_x := roundi(block_x + cell_size / 2.)
	var portrait_y := roundi(block_y + cell_size / 2.)
	var portrait_w := floori(6.5 * cell_size)
	
	Splatmap.register_draw(SplatDrawBoxCmd.new(panel_1, Vector2i(block_x, block_y), Vector2i(block_w, block_h), true, 1, false))
	Splatmap.register_draw(SplatColorAreaCmd.new(Color.WHITE_SMOKE, Vector2i(portrait_x, portrait_y), Vector2i(portrait_w, portrait_h), 1, false))
	_draw_str("Character", char_name_start, Vector2i(5, 8), 0)
	char_y += 10
	_draw_str("HP 999/999", char_name_start + Vector2i(0, char_y), Vector2i(5, 8), 0)
	char_y += 9
	Splatmap.register_draw(SplatColorAreaCmd.new(hp_bar_color, char_name_start + Vector2i(0, char_y), Vector2i(52, 1), 1, false))
	char_y += 3
	_draw_str("AP 999/999", char_name_start + Vector2i(0, char_y), Vector2i(5, 8), 0)
	char_y += 9
	Splatmap.register_draw(SplatColorAreaCmd.new(ap_bar_color, char_name_start + Vector2i(0, char_y), Vector2i(52, 1), 1, false))


func _draw_str(text: String, pos: Vector2i, char_size: Vector2i, _line_spacing: float) -> void:
	var offset := Vector2i()
	for character in text:
		var sample := Vector2i(-1, -1)
		if character.is_valid_int():
			sample = _get_num_pos(character)
		elif character in '[]()/?!+-%=_':
			sample = _get_symbol_pos(character)
		elif character != " ":
			sample = _get_char_pos(character)
		
		if sample != Vector2i(-1, -1):
			Splatmap.register_draw(SplatDrawTransparentCmd.new(sample, pos + offset, 1, false));
		offset += Vector2i(char_size.x, 0)


func _get_char_pos(character: String) -> Vector2i:
	const chars := 'ABCDEFGHIJKLMNOPQRSTQVWXYZ'
	var upper = character.to_upper()
	var index := chars.find(upper)
	if upper == character:
		return Vector2i(index, 27)
	else:
		return Vector2i(index, 28)


func _get_num_pos(num: String) -> Vector2i:
	const chars := '0123456789'
	var index := chars.find(num)
	return Vector2i(index, 29)


func _get_symbol_pos(symbol: String) -> Vector2i:
	const chars := '[]()/?!+-%=_'
	var index := chars.find(symbol)
	return Vector2i(index, 30)


func _resize() -> void:
	_resize_pixel_perfect()
	_place_at_center()


func _resize_pixel_perfect() -> void:
	var parent := get_parent_control()
	var parent_size := parent.size
	
	var splatmap_size: Vector2i = ProjectSettings.get_setting("splatmap/canvas_size")
	var ratio_x := floori(parent_size.x / splatmap_size.x)
	var ratio_y := floori(parent_size.y / splatmap_size.y)
	var lowest_common := mini(ratio_x, ratio_y)
	size = splatmap_size * lowest_common


func _place_at_center() -> void:
	var parent := get_parent_control()
	var parent_size := parent.size
	
	var x_pos := roundi((parent_size.x - size.x) / 2.0)
	var y_pos := roundi((parent_size.y - size.y) / 2.0)
	position = Vector2i(x_pos, y_pos)


func on_viewport_size_changed():
	_resize()
