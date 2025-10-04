## TEMPLATE_NODE : General-purpose script structure for nodes

## ================================================================
## Script: %FILE_NAME%
## Description: Brief description of what this script does
## Author: YourName
## ================================================================

extends Node2D
class_name Unit

## -----------------------------
## Signals
## -----------------------------


## -----------------------------
## Constants
## -----------------------------
enum UnitAction {ATTACK, MOVE, HOLD}

## -----------------------------
## Exported variables (tweakable in editor)
## -----------------------------


## -----------------------------
## Member variables
## -----------------------------
@onready var board = get_tree().get_first_node_in_group("board") as Board
@onready var battle_manager = get_tree().get_first_node_in_group("battle_manager") as BattleManager
@onready var alligiance_border: ColorRect = $Area2D/AlligienceBorder
@onready var action_cooldown: Timer = $ActionCooldown

var is_dragging: bool = false
var offset: Vector2
var current_tile: Tile = null
var is_on_board: bool = false

# Unit Name
var unit_name: String = "Unit Name"

# Core stats (base defaults, can be overridden by subclasses)
var attack_damage: int = 1
var armour: int = 0
var health: int = 5
var attack_range: int = 1
var attack_rate: float = 1.5 # attacks per second
var leadership: float = 50

# Upkeep stats
var cost = 100
var upkeep = 25

# Battle
var allegiance: Defs.Allegiance = Defs.Allegiance.UNIT_PLAYER
var can_act: bool = true
var target: Unit = null
var path: Array

## -----------------------------
## Built-in callbacks
## -----------------------------
func _ready() -> void:
	_init_signals()
	_init_defaults()


func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position()
		
	if is_on_board and battle_manager.battle_state == Defs.BattleState.RUNNING and can_act:
		_update_next_action()


## -----------------------------
## Public methods
## -----------------------------
func init_unit() -> void:
	print("unit.init_unit() called")
	_init_signals()
	_init_defaults()


func get_current_tile() -> Tile:
	return current_tile


func return_to_original_position() -> void:
	# No longer used in favour of _request_removal
	if current_tile:
		global_position = current_tile.global_position


func take_damage(amount: int) -> void:
	var damage_taken = max(amount - armour, 0)
	health -= damage_taken
	if health <= 0:
		queue_free()

func notify_move_result(success: bool) -> void:
	if success:
		_perform_action(UnitAction.MOVE)


## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	if action_cooldown and not action_cooldown.is_connected("timeout", Callable(self, "_on_action_cooldown_timeout")):
		action_cooldown.timeout.connect(_on_action_cooldown_timeout)


func _init_defaults() -> void:
	_update_allegiance_border()


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not board.is_setting_up_board: return 
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			offset = get_global_mouse_position() - global_position
		else:
			is_dragging = false
			_request_drop()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_request_removal()


func _request_drop() -> void:	
	if board:
		board.try_place_unit(self)


func _request_removal() -> void:
	board.remove_unit(self)


func _update_allegiance_border() -> void:
	match allegiance:
		Defs.Allegiance.UNIT_PLAYER:
			alligiance_border.color = Color(0, 1, 0)
		Defs.Allegiance.UNIT_ENEMY:
			alligiance_border.color = Color(1, 0, 0)
		Defs.Allegiance.UNIT_ALLY:
			alligiance_border.color = Color(0, 0, 1)
		Defs.Allegiance.UNIT_NEUTRAL:
			alligiance_border.color = Color(1, 1, 0)


func _update_next_action() -> void:
	## Attack target
	if _can_attack():
		_perform_action(UnitAction.ATTACK)
		return
	if _can_move():
		_find_and_set_nearest_enemy()
		_request_move()
	## Find target
	pass


func _perform_action(action: UnitAction) -> void:
	match action:
		UnitAction.ATTACK:
			#print("> unit %s is attacking %s" % [self, target])
			target.take_damage(attack_damage)
			action_cooldown.start(1 / attack_rate)
			can_act = false
		UnitAction.MOVE:
			action_cooldown.start(1 / attack_rate)
			can_act = false
		UnitAction.HOLD:
			pass


func _can_attack() -> bool:
	var enemies_in_range = board.get_occupied_neighbours(current_tile, attack_range).filter(func(n): return _is_enemy(self, n.occupying_unit))
	if enemies_in_range.is_empty():
		return false
	if not target:
		target = enemies_in_range.pick_random().occupying_unit
	return true


func _can_move() -> bool:
	return true


func _determine_path_to_target(target_tile: Tile) -> Array:
	return board.get_shortest_path(current_tile, target_tile)



func _request_move() -> bool:
	if not target: 
		return false

	path = _determine_path_to_target(target.current_tile)
	if path.is_empty():
		return false
	
	var next_tile = path[0]  # just the next step
	return board.try_queue_move(self, next_tile)


func _find_and_set_nearest_enemy() -> Unit:
	var all_enemies = board.get_all_occupied_tiles().filter(func(n): return _is_enemy(self, n.occupying_unit))
	if all_enemies.is_empty():
		return null
	var closest_enemy = board.get_closest_tile_in_tiles(current_tile, all_enemies).occupying_unit
	target = closest_enemy
	return closest_enemy


func _is_enemy(unit: Unit, target) -> bool:
	if unit and target:
		return not unit.allegiance == target.allegiance
	return false


func _on_action_cooldown_timeout() -> void:
	can_act = true
