extends UIComponentBase

const text_length := 44


func _init() -> void:
	_observed_states = [
		"ui", "ui.layer", "ui.cmdbar.visible", "ui.cmdbar.text",
		"world.player.facing"
	]


func update() -> void:
	var vis: bool = owner.get_state("ui.cmdbar.visible", false)
	
	if vis:
		if not _cmds.is_empty():
			_unregister_draws()
		_register_draws()
	elif !vis:
		_unregister_draws()


func _process(_delta: float) -> void:
	pass


func _register_draws() -> void:
	var ui_layer = owner.get_state("ui.layer", 0)
	var start_pos := Vector2i(1, 16)
	var start_px_pos := start_pos * Vram.CELL_SIZE
	var comp_size := Vector2i(30, 2)
	
	_register_draw(ui_layer, SplatDrawBoxCmd.create({
		"tl": Vector2i(3, 0), "tc": Vector2i(4, 0), "tr": Vector2i(5, 0),
		"ml": Vector2i(3, 1), "mc": Vector2i(4, 1), "mr": Vector2i(5, 1),
		"bl": Vector2i(3, 2), "bc": Vector2i(4, 2), "br": Vector2i(5, 2)
	}, start_pos, comp_size, true, true))
	
	_register_draw(ui_layer, SplatDrawDecalCmd.create(Vector2i(6, 0), start_px_pos + Vector2i(3, 4), false, false, false))
	
	# Draw Text
	var player_facing = owner.get_state("world.player.facing", 0)
	#var text := "%44s" % DungeonDirection.Facing.keys()[player_facing]
	var text := "%s" % DungeonDirection.Facing.keys()[player_facing]
	
	_cmds.append_array(TextRenderUtils.register_line(
		Vector2i(0, 8), text, Vector2i(5, 8), start_px_pos + Vector2i(15, 4), ui_layer
	))


func _unregister_draws() -> void:
	var ui_layer = owner.get_state("ui.layer", 0)
	for cmd in _cmds:
		Splatmap.unregister_cmd(ui_layer, cmd)
	_cmds.clear()
