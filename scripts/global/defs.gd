## TEMPLATE_NODE : General-purpose script structure for nodes

## ================================================================
## Script: %FILE_NAME%
## Description: Global definitions such as enums
## Author: M Foster
## ================================================================

extends Node

enum Allegiance {UNIT_PLAYER, UNIT_ENEMY, UNIT_NEUTRAL, UNIT_ALLY}
enum BattleState { SETUP , RUNNING, FINISHED }


func flatten_array(array: Array) -> Array:
	var result: Array = []
	for nested in array:
		if nested is Array:
			result.append_array(nested)
		else:
			result.append(nested)
	return result
