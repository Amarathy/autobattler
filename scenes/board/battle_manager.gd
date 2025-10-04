## TEMPLATE_NODE : General-purpose script structure for nodes

## ================================================================
## Script: BattleManager.gd
## Description: Controls the high-level state of a battle
## Author: M Foster
## ================================================================

extends Node
class_name BattleManager


## -----------------------------
## Signals
## -----------------------------
signal battle_state_changed(new_state: Defs.BattleState)


## -----------------------------
## Constants
## -----------------------------


## -----------------------------
## Exported variables (tweakable in editor)
## -----------------------------


## -----------------------------
## Member variables
## -----------------------------
@onready var battle_state_label: Label = $BattleState
@onready var battle_start_button: Button = $StartBattle

var battle_state: int = -1


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
func set_battle_state(new_state: Defs.BattleState) -> void:
	if battle_state != new_state:
		battle_state = new_state
		_update_label(new_state)
		battle_state_changed.emit(new_state)


func get_battle_state() -> int:
	return battle_state


## -----------------------------
## Private helpers
## -----------------------------
func _init_signals() -> void:
	add_to_group("battle_manager")


func _init_defaults() -> void:
	set_battle_state(Defs.BattleState.SETUP)
	_update_label(battle_state)

func _update_label(new_state: Defs.BattleState) -> void:
	match new_state:
		Defs.BattleState.SETUP:
			battle_state_label.text = "Set Up"
		Defs.BattleState.RUNNING:
			battle_state_label.text = "Running"
		Defs.BattleState.FINISHED:
			battle_state_label.text = "Finished"


func _on_start_battle_pressed() -> void:
	set_battle_state(Defs.BattleState.RUNNING)
	battle_start_button.queue_free()
