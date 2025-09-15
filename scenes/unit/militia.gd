## TEMPLATE_NODE : General-purpose script structure for nodes

## ================================================================
## Script: %FILE_NAME%
## Description: Brief description of what this script does
## Author: M Foster
## ================================================================

extends Unit
class_name Militia


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


## -----------------------------
## Built-in callbacks
## -----------------------------
func _ready() -> void:
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)


## -----------------------------
## Public methods
## -----------------------------


## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	pass


func _init_defaults() -> void:
	_set_init_stats()
	_set_init_name()

func _set_init_stats() -> void:
	attack = 2
	armour = 0
	health = 8
	attack_range = 1
	attack_rate = 1.8

func _set_init_name() -> void:
	unit_name = "Militia"
