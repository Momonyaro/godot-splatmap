extends RefCounted

const MAX_CMD_ID := 16255

var image: Image
var commands: Dictionary[int, SplatCmd] = {}
var immediate_commands: Array[SplatCmd] = []
var effects: Dictionary[String, SplatEffect] = {}

var dirty := true
var visible := true
var draw_fast := false
var _last_id := -1
var _layer_index := 0


func _init(index: int, size: Vector2i) -> void:
	_layer_index = index
	image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)

func render(context: Dictionary) -> void:
	if not dirty:
		return
	
	#print('rendering layer %d...' % _layer_index)
	
	image.fill(Color.TRANSPARENT)
	for cmd in commands.values():
		cmd.execute(image, context)
	for cmd in immediate_commands:
		cmd.execute(image, context)
	dirty = false


func add_immediate(cmd: SplatCmd) -> void:
	immediate_commands.push_back(cmd)
	dirty = true


func add_command(cmd: SplatCmd) -> int:
	_last_id += 1
	while commands.has(_last_id):
		_last_id += 1
		
	commands[_last_id] = cmd
	dirty = true
	return _last_id


func remove_command(id: int) -> bool:
	dirty = true
	return commands.erase(id)


func apply_effects(delta: float) -> void:
	for effect in effects.values():
		effect.tick(delta)
		effect.apply_to_image(image)
	
	if effects.size() > 0:
		dirty = true


func has_commands() -> bool:
	return immediate_commands.size() > 0 or commands.size() > 0


func flush() -> void:
	if immediate_commands.size() == 0:
		return
	immediate_commands.clear()
	dirty = true


func clear_commands() -> void:
	commands.clear()
	dirty = true
