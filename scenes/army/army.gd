## TEMPLATE_NODE : General-purpose script structure for nodes

## ================================================================
## Script: Army.gd
## Description: Manages a collection of units belonging to an army
## Author: M Foster
## ================================================================

extends Node2D
class_name Army

## -----------------------------
## Signals
## -----------------------------
signal unit_added(unit)
signal unit_removed(unit)

## -----------------------------
## Constants
## -----------------------------


## -----------------------------
## Exported variables (tweakable in editor)
## -----------------------------
@export var army_name: String = "New Army"

## -----------------------------
## Member variables
## -----------------------------
var units: Array = []

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
func add_unit(unit: Unit) -> void:
	if not units.has(unit):
		units.append(unit)
		add_child(unit)
		emit_signal("unit_added", unit)

func remove_unit(unit: Unit) -> void:
	if units.has(unit):
		units.erase(unit)
		unit.queue_free()
		emit_signal("unit_removed", unit)

func get_unit_count() -> int:
	return units.size()

func get_units() -> Array:
	return units.duplicate()


## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	pass

func _init_defaults() -> void:
	pass
