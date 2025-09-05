## TEMPLATE_NODE : General-purpose script structure for nodes

## ================================================================
## Script: %FILE_NAME%
## Description: Brief description of what this script does
## Author: YourName
## ================================================================


extends Node

#class_name %CLASS%


## -----------------------------
## Signals
## -----------------------------
#signal something_happened(param)


## -----------------------------
## Constants
## -----------------------------
#const MAX_HEALTH := 100


## -----------------------------
## Exported variables (tweakable in editor)
## -----------------------------
#@export var health: int = MAX_HEALTH
#@export var attack_power: int = 10


## -----------------------------
## Member variables
## -----------------------------
#var is_alive: bool = true


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
#func take_damage(amount: int) -> void:
	#health -= amount
	#if health <= 0:
		#_die()
#
#
#func attack(target: Node) -> void:
	#if target and target.has_method("take_damage"):
		#target.take_damage(attack_power)
		#emit_signal("something_happened", target)


## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	# Example: connect to global event bus
	pass


func _init_defaults() -> void:
	pass

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/board/Board.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
