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


## -----------------------------
## Exported variables (tweakable in editor)
## -----------------------------


## -----------------------------
## Member variables
## -----------------------------
@onready var board = get_tree().get_first_node_in_group("board") as Board

var is_dragging: bool = false
var offset: Vector2
var current_tile: Tile = null
var is_on_board: bool = false

# Unit Name
var unit_name: String = "Unit Name"

# Core stats (base defaults, can be overridden by subclasses)
var attack: int = 1
var armour: int = 0
var health: int = 5
var attack_range: int = 1
var attack_rate: float = 1.5 # attacks per second
var leadership: float = 50

# Upkeep stats
var cost = 100
var upkeep = 25


## -----------------------------
## Built-in callbacks
## -----------------------------
func _ready() -> void:
	_init_signals()
	_init_defaults()


func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position()


## -----------------------------
## Public methods
## -----------------------------
func init_unit() -> void:
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
		queue_free() # Placeholder for "unit dies"

## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	pass

func _init_defaults() -> void:
	pass

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
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
