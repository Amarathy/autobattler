## TEMPLATE_NODE : General-purpose script structure for nodes

## ================================================================
## Script: %FILE_NAME%
## Description: Brief description of what this script does
## Author: YourName
## ================================================================

extends Node2D
class_name Tile

## -----------------------------
## Signals
## -----------------------------



## -----------------------------
## Constants
## -----------------------------



## -----------------------------
## Exported variables (tweakable in editor)
## -----------------------------
@export var grid_x: int
@export var grid_y: int


## -----------------------------
## Member variables
## -----------------------------
var occupied: bool = false
var occupying_unit: Unit = null


## -----------------------------
## Built-in callbacks
## -----------------------------
func _ready() -> void:
	_init_signals()
	_init_defaults()


func _process(_delta: float) -> void:
	pass



## -----------------------------
## Public methods
## -----------------------------

func set_highlight(state: bool) -> void:
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1, 1, 0.5) if state else Color(1, 1, 1)

func set_tile_to_occupied(unit: Unit) -> void:
	occupying_unit = unit
	occupied = true

func set_tile_to_unoccupied() -> void:
	occupying_unit = null
	occupied = false

## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	# Example: connect to global event bus
	pass


func _init_defaults() -> void:
	pass


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseMotion:
		set_highlight(true)

func _on_area_2d_mouse_exited() -> void:
	set_highlight(false)
