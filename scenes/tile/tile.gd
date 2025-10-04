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
# Grid positions used by Board
@export var grid_x: int
@export var grid_y: int

# Slots used by Army Manager
@export var bench_slot: int

## Geometry
@export var size: Vector2 = Vector2(64.0, 64.0)

## -----------------------------
## Member variables
## -----------------------------
var occupied: bool
var occupying_unit: Unit = null
var highlighted: bool = false
var board: Board

# Children
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

## -----------------------------
## Built-in callbacks
## -----------------------------
func _ready() -> void:
	_init_signals()
	_init_defaults()


func _process(_delta: float) -> void:
	if highlighted:
		board.highlighted_tile = self


## -----------------------------
## Public methods
## -----------------------------

func set_highlight(state: bool) -> void:
	highlighted = state
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1, 1, 0.5) if state else Color(1, 1, 1)

func set_tile_to_occupied(unit: Unit) -> void:
	occupying_unit = unit
	occupied = true

func set_tile_to_unoccupied() -> void:
	occupying_unit = null
	occupied = false

func is_occupied() -> bool:
	return occupied

## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	# Example: connect to global event bus
	pass


func _init_defaults() -> void:
	board = get_tree().get_first_node_in_group("board")
	


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseMotion:
		set_highlight(true)

func _on_area_2d_mouse_exited() -> void:
	set_highlight(false)
	if board.highlighted_tile == self:
		board.clear_highlighted_tile()


func _set_children_size() -> void:
	sprite_2d.size = size
	collision_shape_2d.size = size
