extends UIComponentBase

var _cmds := []


func setup(ui: Node) -> void:
	_ui = ui


func update() -> void:
	var vis: bool = _ui.get_state("cmdbar.visible", false)
	
	if vis and _cmds.is_empty():
		_register_draws()
	elif not vis:
		_unregister_draws()


func _process(_delta: float) -> void:
	pass


func _register_draws() -> void:
	var ui_layer = _ui.get_state("layer")
	Splatmap.register_draw(SplatDrawBoxCmd.new({
		"tl": Vector2i(3, 0), "tc": Vector2i(4, 0), "tr": Vector2i(5, 0),
		"ml": Vector2i(3, 1), "mc": Vector2i(4, 1), "mr": Vector2i(5, 1),
		"bl": Vector2i(3, 2), "bc": Vector2i(4, 2), "br": Vector2i(5, 2)
	}, Vector2i(1, 16), Vector2i(30, 2), true, ui_layer))


func _unregister_draws() -> void:
	var ui_layer = _ui.get_state("layer")
	for cmd in _cmds:
		Splatmap.unregister_draw(ui_layer, cmd)
	_cmds.clear()
