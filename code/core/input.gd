extends Node

## [input.gd]
## Handles input events.

var _moving := false
var _turning := 0
var _turn_dir := 0

var _target_position := Vector2i()
var _target_facing := 0

var _observed_states := [
	"input.allow_move", "input.allow_turn", "input.moving", "input.turning"
]

var _initial_input_state: Dictionary = {
	"input.allow_move": true, "input.allow_turn": true,
	"input.moving": _moving, "input.turning": _turning,
	"input.move_dir": Vector2i(), "input.turn_dir": _turn_dir
}


func _enter_tree() -> void:
	owner.state_updated.connect(_on_state_updated)


func _exit_tree() -> void:
	owner.state_updated.disconnect(_on_state_updated)


func _ready() -> void:
	var bulk_keys := []
	var bulk_values := []
	for key in _initial_input_state.keys():
		bulk_keys.push_back(key)
		bulk_values.push_back(_initial_input_state[key])
	
	owner.bulk_set_state("input", bulk_keys, bulk_values)


func update() -> void:
	_moving = owner.get_state("input.moving", _moving)
	_turning = owner.get_state("input.turning", _turning)


func _input(event: InputEvent) -> void:
	if _turning > 0 or _moving:
		return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_RIGHT:
			_turn(1)
		elif event.keycode == KEY_LEFT:
			_turn(-1)
		elif event.keycode == KEY_DOWN:
			_turn(2)
		elif event.keycode == KEY_UP:
			_try_step()


func _turn(delta: int) -> void:
	_target_facing = owner.get_state("world.player.facing", 0) + signi(delta)
	if _target_facing >= 4: _target_facing -= 4
	if _target_facing < 0: _target_facing += 4
	_turn_dir = signi(delta)
	_turning = absi(delta)
	owner.set_state("input.turn_dir", _turn_dir)
	owner.set_state("input.turning", _turning)


func _try_step() -> void:
	var can_traverse := true
	var player_pos: Vector2i = owner.get_state("world.player.position", Vector2i())
	var player_facing: int = owner.get_state("world.player.facing", 0)
	
	var edge: DungeonEdgeResource = %Map.get_edge(player_pos, player_facing)
	if edge != null:
		can_traverse = edge.can_traverse
	if can_traverse:
		owner.set_state("input.move_dir", DungeonDirection.get_vector(player_facing))
	else:
		owner.set_state("input.move_dir", Vector2i())
	
	_moving = true
	owner.set_state("input.moving", _moving)


func _on_state_updated(key: String, _value: Variant) -> void:
	if key in _observed_states:
		update()
