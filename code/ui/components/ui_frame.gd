extends UIComponentBase

## [ui_frame.gd]
## Frame surrounding game view when in-game


func _init() -> void:
	_observed_states = [
		"ui", "ui.layer", "ui.frame.visible"
	]

func update() -> void:
	var vis: bool = owner.get_state("ui.frame.visible", false)
	
	if vis and _cmds.is_empty():
		_register_draws()
	elif not vis:
		_unregister_draws()


func _register_draws() -> void:
	var panel_1: Dictionary[String, Vector2i] = {
		"tl": Vector2i(0, 0), "tc": Vector2i(1, 0), "tr": Vector2i(2, 0),
		"ml": Vector2i(0, 1), "mc": Vector2i(1, 1), "mr": Vector2i(2, 1),
		"bl": Vector2i(0, 2), "bc": Vector2i(1, 2), "br": Vector2i(2, 2)
	}
	
	var ui_layer = owner.get_state("ui.layer")
	
	# TOP BAR
	_register_draw(ui_layer, SplatDrawBoxCmd.create(panel_1, Vector2i(-1, -1), Vector2i(2, 3), true, true))
	_register_draw(ui_layer, SplatDrawBoxCmd.create(panel_1, Vector2i(1, -1), Vector2i(30, 3), true, true))
	_register_draw(ui_layer, SplatDrawBoxCmd.create(panel_1, Vector2i(31, -1), Vector2i(2, 3), true, true))
	
	# VIEWPORT SIDES
	_register_draw(ui_layer, SplatDrawBoxCmd.create(panel_1, Vector2i(-1, 2), Vector2i(2, 14), true, true))
	_register_draw(ui_layer, SplatDrawBoxCmd.create(panel_1, Vector2i(31, 2), Vector2i(2, 14), true, true))
	
	# CMD SIDES
	_register_draw(ui_layer, SplatDrawBoxCmd.create(panel_1, Vector2i(-1, 16), Vector2i(2, 2), true, true))
	_register_draw(ui_layer, SplatDrawBoxCmd.create(panel_1, Vector2i(31, 16), Vector2i(2, 2), true, true))
	
	# LIST SIDES
	_register_draw(ui_layer, SplatDrawBoxCmd.create(panel_1, Vector2i(-1, 18), Vector2i(2, 9), true, true))
	_register_draw(ui_layer, SplatDrawBoxCmd.create(panel_1, Vector2i(31, 18), Vector2i(2, 9), true, true))
	
	# BOTTOM BAR
	_register_draw(ui_layer, SplatDrawBoxCmd.create(panel_1, Vector2i(-1, 27), Vector2i(2, 2), true, true))
	_register_draw(ui_layer, SplatDrawBoxCmd.create(panel_1, Vector2i(1, 27), Vector2i(30, 2), true, true))
	_register_draw(ui_layer, SplatDrawBoxCmd.create(panel_1, Vector2i(31, 27), Vector2i(2, 2), true, true))


func _unregister_draws() -> void:
	var ui_layer = owner.get_state("ui.layer")
	for cmd in _cmds:
		Splatmap.unregister_cmd(ui_layer, cmd)
	_cmds.clear()
