## TEMPLATE_NODE : General-purpose script structure for nodes

## ================================================================
## Script: %FILE_NAME%
## Description: Brief description of what this script does
## Author: M Foster
## ================================================================

extends Node
#class_name Class


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
	_init_signals()
	_init_defaults()


func _process(delta: float) -> void:
	pass


## -----------------------------
## Public methods
## -----------------------------


## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	pass


func _init_defaults() -> void:
	pass
