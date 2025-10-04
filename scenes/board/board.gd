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
@onready var tile_container: Node2D = $TileContainer

var tiles: Array = []
var flat_tiles: Array = []
var start_offset: Vector2
var highlighted_tile: Tile = null

var is_setting_up_board: bool = false

var move_requests: Array = []

## -----------------------------
## Built-in callbacks
## -----------------------------
func _ready() -> void:
	_init_signals()
	_init_defaults()


func _process(_delta: float) -> void:
	resolve_moves()


## -----------------------------
## Public methods
## -----------------------------
func try_place_unit(unit: Unit) -> bool:
	if highlighted_tile and _is_legal_move(highlighted_tile, unit):
		var current_tile = unit.get_current_tile()
		_move_unit(unit, highlighted_tile, current_tile)
		unit_placed.emit(unit, highlighted_tile)
		get_unoccupied_neighbours(highlighted_tile, 1)
		return true
	else:
		remove_unit(unit)
		return false


func remove_unit(unit: Unit) -> void:
	if unit.current_tile:
		unit.current_tile.set_tile_to_unoccupied()
		unit.current_tile = null
	unit.is_on_board = false
	unit_removed.emit(unit)


func clear_highlighted_tile() -> void:
	highlighted_tile = null


func get_tile(x: int, y: int) -> Tile:
	if x >= 0 and x < grid_size.x and y >= 0 and y < grid_size.y:
		return tiles[x][y]
	return null


func get_distance_between_tiles(tile_1: Tile, tile_2: Tile) -> int:
	var dx = abs(tile_1.grid_x - tile_2.grid_x)
	var dy = abs(tile_1.grid_y - tile_2.grid_y)
	return max(dx, dy)


func is_in_range(unit_tile: Tile, target_tile: Tile, range: int) -> bool:
	return get_distance_between_tiles(unit_tile, target_tile) <= range


func get_closest_tile_in_tiles(current_tile: Tile, tiles: Array) -> Tile:
	if tiles.is_empty():
		push_warning("Board: get closest tile from tile called with empty tiles array")
		return null

	var closest_tile: Tile
	var closest_distance = INF

	for t in tiles:
		var distance = get_distance_between_tiles(current_tile, t)

		# Bias for same rank/file
		if current_tile.grid_x == t.grid_x or current_tile.grid_y == t.grid_y:
			distance -= 0.01  # or tweak the value to increase preference

		if distance < closest_distance:
			closest_distance = distance
			closest_tile = t

	return closest_tile


func get_all_neighbours(tile: Tile, radius: int) -> Array:
	var neighbours := []
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var neighbour = get_tile(tile.grid_x + x, tile.grid_y + y)
			if neighbour and not (neighbour == tile):
				neighbours.append(neighbour)
	return neighbours


func get_unoccupied_neighbours(tile: Tile, radius: int) -> Array:
	return get_all_neighbours(tile, radius).filter(func(n): return not n.occupied)


func get_occupied_neighbours(tile: Tile, radius: int) -> Array:
	return get_all_neighbours(tile, radius).filter(func(n): return n.occupied)


func get_all_occupied_tiles() -> Array:
	var occupied_tiles: Array = flat_tiles.filter(func(n): return n.occupied)
	return occupied_tiles


func get_shortest_path(start: Tile, goal: Tile, attack_range: int = 1) -> Array:
	# Already in range? No movement needed
	if get_distance_between_tiles(start, goal) <= attack_range:
		return []

	var frontier: Array = [start]
	var came_from := {}
	came_from[start] = null

	var goal_reached: Tile = null

	while not frontier.is_empty():
		var current: Tile = frontier.pop_front()

		# Check if current tile is in attack range of the goal
		if get_distance_between_tiles(current, goal) <= attack_range:
			goal_reached = current
			break

		# Cardinal neighbours first, then diagonals
		var offsets = [
			Vector2i(0, -1),  # up
			Vector2i(0, 1),   # down
			Vector2i(-1, 0),  # left
			Vector2i(1, 0),   # right
			Vector2i(-1, -1), # diag up-left
			Vector2i(1, -1),  # diag up-right
			Vector2i(-1, 1),  # diag down-left
			Vector2i(1, 1)    # diag down-right
		]

		for offset in offsets:
			var neighbour = get_tile(current.grid_x + offset.x, current.grid_y + offset.y)
			if neighbour and (not neighbour.is_occupied() or neighbour == goal):
				if not came_from.has(neighbour):
					frontier.append(neighbour)
					came_from[neighbour] = current

	# No valid path found
	if not goal_reached:
		print("No path found. Start:%s Goal:%s" % [start, goal])
		return []

	# Reconstruct path to the chosen tile
	var path: Array = []
	var current: Tile = goal_reached
	while current and current != start:
		path.push_front(current)
		current = came_from[current]

	return path




func try_queue_move(unit: Unit, target_tile: Tile) -> bool:
	if not _is_legal_move(target_tile, unit):
		return false
	move_requests.append({"unit": unit, "tile": target_tile})
	return true


func resolve_moves() -> void:
	var claimed_tiles := {}
	var move_results := {}  # unit -> bool

	for request in move_requests:
		var unit: Unit = request.unit
		var tile: Tile = request.tile
		if claimed_tiles.has(tile):
			move_results[unit] = false
			continue
		
		# Attempt to move
		if _is_legal_move(tile, unit):
			_move_unit(unit, tile, unit.current_tile)
			claimed_tiles[tile] = unit
			move_results[unit] = true
		else:
			move_results[unit] = false

	move_requests.clear()

	for unit in move_results.keys():
		unit.notify_move_result(move_results[unit])


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
	var grid_pixel_size = Vector2(
		grid_size.x * tile_spacing.x,
		grid_size.y * tile_spacing.y
	)

	# Offset so grid is centred in the viewport
	var viewport_size = get_viewport_rect().size
	start_offset = (viewport_size - grid_pixel_size + tile_spacing) / 2.0

	for x in grid_size.x:
		tiles.append([])
		for y in grid_size.y:
			var tile = tile_scene.instantiate() as Tile
			tile.name = "Tile" + "x" + str(x) + "y" + str(y)
			tile.grid_x = x
			tile.grid_y = y
			tile.position = start_offset + Vector2(x * tile_spacing.x, y * tile_spacing.y)
			tile_container.add_child(tile)
			tiles[x].append(tile)
	flat_tiles = Defs.flatten_array(tiles)


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


func _on_battle_manager_battle_state_changed(new_state: Defs.BattleState) -> void:
	match new_state:
		Defs.BattleState.SETUP:
			is_setting_up_board = true
		Defs.BattleState.RUNNING:
			is_setting_up_board = false
		Defs.BattleState.FINISHED:
			is_setting_up_board = false
