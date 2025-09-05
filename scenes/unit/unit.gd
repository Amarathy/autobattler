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
var is_dragging: bool = false
var offset: Vector2
var current_tile: Tile = null

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
func get_current_tile() -> Tile:
	return current_tile

func return_to_original_position() -> void:
	if current_tile:
		global_position = current_tile.global_position

## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	# Example: connect to global event bus
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

func _request_drop() -> void:
	var board = get_tree().get_first_node_in_group("board") as Board
	if board:
		board.try_place_unit(self)
