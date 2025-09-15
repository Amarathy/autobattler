## TEMPLATE_NODE : General-purpose script structure for nodes

## ================================================================
## Script: %FILE_NAME%
## Description: Brief description of what this script does
## Author: YourName
## ================================================================


extends Node2D

class_name Board


## -----------------------------
## Signals
## -----------------------------
signal unit_placed(unit: Unit, tile: Tile)
signal unit_removed(unit: Unit)

## -----------------------------
## Constants
## -----------------------------



## -----------------------------
## Exported variables (tweakable in editor)
## -----------------------------
@export var tile_scene: PackedScene
@export var grid_size: Vector2i = Vector2i(12, 12)
@export var tile_spacing: Vector2 = Vector2(64, 64)  # pixel distance between tiles


## -----------------------------
## Member variables
## -----------------------------
var tiles: Array = []
var start_offset: Vector2
var highlighted_tile: Tile = null

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
func try_place_unit(unit: Unit) -> bool:
	if highlighted_tile and _is_legal_move(highlighted_tile, unit):
		var current_tile = unit.get_current_tile()
		_move_unit(unit, highlighted_tile, current_tile)
		unit_placed.emit(unit, highlighted_tile)
		return true
	else:
		remove_unit(unit)
		#unit.return_to_original_position()
		return false

func remove_unit(unit: Unit) -> void:
	if unit.current_tile:
		unit.current_tile.set_tile_to_unoccupied()
		unit.current_tile = null
	unit.is_on_board = false
	unit_removed.emit(unit)

func clear_highlighted_tile() -> void:
	highlighted_tile = null

## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	# Example: connect to global event bus
	pass

func _init_defaults() -> void:
	add_to_group("board")
	_create_grid()

func _create_grid() -> void:
	# Calculate total pixel size of the grid
	var grid_pixel_size = Vector2(
		grid_size.x * tile_spacing.x,
		grid_size.y * tile_spacing.y
	)

	# Offset so grid is centred in the viewport
	var viewport_size = get_viewport_rect().size
	start_offset = (viewport_size - grid_pixel_size) / 2.0

	for x in grid_size.x:
		tiles.append([])
		for y in grid_size.y:
			var tile = tile_scene.instantiate() as Tile
			tile.grid_x = x
			tile.grid_y = y
			tile.position = start_offset + Vector2(x * tile_spacing.x, y * tile_spacing.y)
			add_child(tile)
			tiles[x].append(tile)

func _is_legal_move(tile: Tile, _unit: Unit) -> bool:
	if tile:
		return tile.occupying_unit == null
	return false

func _move_unit(unit: Unit, placing_tile: Tile, current_tile: Tile) -> void:
	placing_tile.set_tile_to_occupied(unit)
	if current_tile:
			current_tile.set_tile_to_unoccupied() 
	unit.current_tile = placing_tile
	unit.global_position = placing_tile.global_position
	unit.is_on_board = true
