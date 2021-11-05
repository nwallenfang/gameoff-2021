extends Node

export var PLAYER_PROJECTILE_DAMAGE := 2
export var PLAYER_MAX_HEALTH := 3

var CURRENT_HEALTH = PLAYER_MAX_HEALTH setget set_health

var CURRENT_YSORT
var CURRENT_UI
var CURRENT_PLAYER


func set_health(new_health:int):
	CURRENT_HEALTH = new_health
	CURRENT_UI.get_node("HealthUI").set_hearts(new_health)
	
