## TEMPLATE_NODE : General-purpose script structure for nodes

## ================================================================
## Script: unit_factory.gd
## Description: Singleton factory for creating units
## Author: YourName
## ================================================================

extends Node

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
var unit_scenes: Dictionary = {
	"Militia" : preload("res://scenes/unit/Militia.tscn")
}  # e.g. {"Warrior": preload("res://units/warrior.tscn")}

## -----------------------------
## Built-in callbacks
## -----------------------------
func _ready() -> void:
	_init_signals()
	_init_defaults()


## -----------------------------
## Public methods
## -----------------------------
func register_unit_type(unit_name: String, scene: PackedScene) -> void:
	unit_scenes[unit_name] = scene

func create_unit(unit_name: String) -> Unit:
	if unit_scenes.has(unit_name):
		var instance = unit_scenes[unit_name].instantiate()
		#instance.init_unit() # Instance not added to scene tree so this calls _ready
		return instance
	push_warning("UnitFactory: Unit type '%s' not registered" % unit_name)
	return null

func get_registered_units() -> Array:
	return unit_scenes.keys()


## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	pass

func _init_defaults() -> void:
	pass
