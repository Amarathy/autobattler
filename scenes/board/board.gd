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
func try_place_unit(unit: Unit) -> void:
	var placing_tile = _get_tile_at_mouse()
	var current_tile = unit.get_current_tile()
	
	if _is_legal_move(placing_tile, unit):
		_move_unit(unit, placing_tile, current_tile)
	else:
		unit.return_to_original_position()


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

func _get_tile_at_mouse() -> Tile:
	var mouse_pos = get_global_mouse_position()
	var grid_x = int((mouse_pos.x - start_offset.x + tile_spacing.x / 2) / tile_spacing.x)
	var grid_y = int((mouse_pos.y - start_offset.y + tile_spacing.y / 2) / tile_spacing.y)

	if grid_x >= 0 and grid_x < grid_size.x and grid_y >= 0 and grid_y < grid_size.y:
		return tiles[grid_x][grid_y] as Tile
	return null

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
