extends UIComponentBase

var _cached_text := ""


func setup(ui: Node) -> void:
	_ui = ui


func update() -> void:
	var vis: bool = _ui.get_state("cmdbar.visible", false)
	var text: String = _ui.get_state("cmdbar.text", "")
	
	var has_changes := false
	if text != _cached_text:
		has_changes = true
		_cached_text = text
	
	if vis and has_changes:
		if not _cmds.is_empty():
			_unregister_draws()
		_register_draws()
	elif !vis:
		_unregister_draws()


func _process(_delta: float) -> void:
	pass


func _register_draws() -> void:
	var ui_layer = _ui.get_state("layer")
	var start_pos := Vector2i(1, 16)
	var start_px_pos := start_pos * Splatmap.Vram.CELL_SIZE
	var comp_size := Vector2i(30, 2)
	
	_register_draw(SplatDrawBoxCmd.new({
		"tl": Vector2i(3, 0), "tc": Vector2i(4, 0), "tr": Vector2i(5, 0),
		"ml": Vector2i(3, 1), "mc": Vector2i(4, 1), "mr": Vector2i(5, 1),
		"bl": Vector2i(3, 2), "bc": Vector2i(4, 2), "br": Vector2i(5, 2)
	}, start_pos, comp_size, true, ui_layer))
	
	_register_draw(SplatDrawTransparentCmd.new(Vector2i(6, 0), start_px_pos + Vector2i(3, 4), ui_layer, false))
	
	# Draw Text
	_cmds.push_back(TextRenderUtils.register_line(
		Vector2i(0, 8), _cached_text, Vector2i(5, 8), start_px_pos + Vector2i(15, 4), ui_layer
	))


func _unregister_draws() -> void:
	var ui_layer = _ui.get_state("layer")
	for cmd in _cmds:
		Splatmap.unregister_draw(ui_layer, cmd)
	_cmds.clear()
