## TEMPLATE_NODE : General-purpose script structure for nodes

## ================================================================
## Script: army_manager.gd
## Description: UI manager for creating and modifying an Army
## Author: M Foster
## ================================================================

extends Control
class_name ArmyManager


## -----------------------------
## Signals
## -----------------------------



## -----------------------------
## Constants
## -----------------------------



## -----------------------------
## Exported variables (tweakable in editor)
## -----------------------------
@export var unit_label_size: Vector2 = Vector2(100, 64)
@export var unit_to_label_offset: Vector2 = Vector2(100, 0)

## -----------------------------
## Member variables
## -----------------------------
var army: Army = null

@onready var create_army_button: Button = $ButtonHBox/CreateArmy
@onready var add_militia_button: Button = $ButtonHBox/AddMilitia
@onready var bench: Control = $Bench

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


## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	create_army_button.pressed.connect(_on_create_army_pressed)
	add_militia_button.pressed.connect(_on_add_militia_pressed)

func _init_defaults() -> void:
	_update_ui()


func _on_create_army_pressed() -> void:
	army = Army.new()
	add_child(army)
	_update_ui()


func _on_add_militia_pressed() -> void:
	if army:
		var militia = UnitFactory.create_unit("Militia")
		army.add_unit(militia)
		_update_ui()

func _update_ui() -> void:
	for child in bench.get_children():
		child.queue_free()
	if not army:
		return
	_create_unit_list_roster()

func _create_unit_list_roster() -> void:
	var i := 0
	for unit in army.get_units():
		if unit.is_on_board:
			continue

		var tile := preload("res://scenes/tile/Tile.tscn").instantiate() as Tile
		tile.bench_slot = i
		bench.add_child(tile)
		tile.position.y = tile.size.y * i

		# Place the unit on the tile
		tile.set_tile_to_occupied(unit)
		unit.current_tile = tile
		unit.global_position = tile.global_position
		i += 1


func _on_board_unit_placed(unit: Unit, tile: Tile) -> void:
	_update_ui()


func _on_board_unit_removed(unit: Unit) -> void:
	_update_ui()
