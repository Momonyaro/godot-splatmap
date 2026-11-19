extends UIComponentBase

## [ui_party_cards.gd]
## Frame surrounding game view when in-game

const ORIGO_PX := Vector2i(8, 144)
const CARD_SIZE_PX := Vector2i(52, 64)
const PORTRAIT_SIZE_PX := Vector2i(51, 32)

func _init() -> void:
	_observed_states = [
		"ui", "ui.layer", "ui.party.visible", "ui.party.items", "battle.active"
	]


func update() -> void:
	var vis: bool = owner.get_state("ui.party.visible", false)
	#TODO: Add check for party data change to reduce updates
	
	if vis:
		if not _cmds.is_empty():
			_unregister_draws()
		_register_draws()
	elif !vis:
		_unregister_draws()


func _register_draws() -> void:
	var ui_layer = owner.get_state("ui.layer")
	var party_data: Array = owner.get_state("ui.party.items", [])
	for i in 4:
		var item = {}
		if party_data.size() > i:
			if party_data[i] != null:
				item = party_data[i]
		_draw_card(i, item, ui_layer)


func _draw_card(index: int, card_data: Dictionary, layer: int) -> void:
	const bg_rect: Dictionary[String, Vector2i] = {
		"tl": Vector2i(0, 0), "tc": Vector2i(1, 0), "tr": Vector2i(2, 0),
		"ml": Vector2i(0, 1), "mc": Vector2i(1, 1), "mr": Vector2i(2, 1),
		"bl": Vector2i(0, 2), "bc": Vector2i(1, 2), "br": Vector2i(2, 2)
	}
	const header := [
		[Vector2i(0, 3), Vector2i(0, 0), false, false, false], 
		[Vector2i(1, 3), Vector2i(1, 0), false, false, false],
		[Vector2i(1, 3), Vector2i(2, 0), false, false, false],
		[Vector2i(1, 3), Vector2i(3, 0), false, false, false],
		[Vector2i(2, 3), Vector2i(4, 0), false, false, true],
	]
	const active_text := [
		[Vector2i(3, 3), Vector2i(0, 0), false, false, true], 
		[Vector2i(4, 3), Vector2i(1, 0), false, false, true],
		[Vector2i(5, 3), Vector2i(2, 0), false, false, true],
	]
	
	var offset := ORIGO_PX + (Vector2i(index, 0) * (CARD_SIZE_PX + Vector2i(8, 0)))
	
	_register_draw(SplatDrawBoxCmd.new(
		bg_rect, offset, CARD_SIZE_PX, true, layer, false
	))
	
	if card_data.is_empty():
		return
	
	_register_draw(SplatColorAreaCmd.new(Color.WHITE_SMOKE, offset + Vector2i(4, 4), PORTRAIT_SIZE_PX, layer, false))
	
	if owner.get_state("battle.active", false):
		_register_draw(SplatDrawComplexCmd.new(header, offset, layer, false))
		_register_draw(SplatDrawComplexCmd.new(active_text, offset + Vector2i(10, 2), layer, false))
		if card_data.get("active", false):
			_register_draw(SplatDrawTransparentCmd.new(Vector2i(3, 4), offset + Vector2i(3, 2), layer, false))
		else:
			_register_draw(SplatDrawTransparentCmd.new(Vector2i(4, 4), offset + Vector2i(3, 2), layer, false))
	
	var char_name: String = card_data.get("name", "")
	_cmds.push_back(TextRenderUtils.register_line(
		Vector2i(0, 8), char_name, Vector2i(5, 8), offset + Vector2i(4, 38), layer
	))
	
	
	var hp_v: Vector2i = card_data.get("hp", Vector2i())
	var hp_str: String = "HP ---/---" if hp_v == Vector2i() else "HP %3d/%3d" % [hp_v.x, hp_v.y]
	var hp_ratio: float = 0.0 if hp_v == Vector2i() else float(hp_v.x) / hp_v.y
	
	_cmds.push_back(TextRenderUtils.register_line(
		Vector2i(0, 8), hp_str, Vector2i(5, 8), offset + Vector2i(4, 48), layer
	))
	_register_draw(SplatColorAreaCmd.new(Color.from_string("080808", Color.BLACK), offset + Vector2i(4, 56), Vector2i(PORTRAIT_SIZE_PX.x, 1), layer, false))
	_register_draw(SplatColorAreaCmd.new(Color.from_string("29cc49", Color.WHITE), offset + Vector2i(4, 56), Vector2i(lerp(0, PORTRAIT_SIZE_PX.x, hp_ratio), 1), layer, false))
	
	var ap_v: Vector2i = card_data.get("ap", Vector2i())
	var ap_str: String = "AP ---/---" if ap_v == Vector2i() else "AP %3d/%3d" % [ap_v.x, ap_v.y]
	var ap_ratio: float = 0.0 if ap_v == Vector2i() else float(ap_v.x) / ap_v.y
	
	_cmds.push_back(TextRenderUtils.register_line(
		Vector2i(0, 8), ap_str, Vector2i(5, 8), offset + Vector2i(4, 58), layer
	))
	_register_draw(SplatColorAreaCmd.new(Color.from_string("080808", Color.BLACK), offset + Vector2i(4, 66), Vector2i(PORTRAIT_SIZE_PX.x, 1), layer, false))
	_register_draw(SplatColorAreaCmd.new(Color.from_string("ff5b5b", Color.WHITE), offset + Vector2i(4, 66), Vector2i(lerp(0, PORTRAIT_SIZE_PX.x, ap_ratio), 1), layer, false))


func _unregister_draws() -> void:
	var ui_layer = owner.get_state("ui.layer")
	for cmd in _cmds:
		Splatmap.unregister_draw(ui_layer, cmd)
	_cmds.clear()
