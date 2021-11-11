extends Node

# start enemy behavior automatically (without calling trigger method or similar)
export var AUTO_ENEMY_BEHAVIOR := false

export var PLAYER_MAX_HEALTH := 4
export var PLAYER_DASH_ACC := 50000.0
export var PLAYER_PROJECTILE_DAMAGE := 4
export var PLAYER_PROJECTILE_KNOCKBACK := 60000.0
export var PLAYER_POISON_DAMAGE := 1
export var PLAYER_POISON_KNOCKBACK := 16000.0

var CURRENT_HEALTH := PLAYER_MAX_HEALTH setget set_health

var CURRENT_YSORT: YSort
var CURRENT_UI: UI
var CURRENT_PLAYER: Player


func set_health(new_health:int):
	CURRENT_HEALTH = new_health
	CURRENT_UI.get_node("HealthUI").set_hearts(new_health)
	

signal input_device_changed
var CONTROLLER_USED := false

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("any_controller_input"):
		if !CONTROLLER_USED:
			CONTROLLER_USED = true
			emit_signal("input_device_changed")
	if Input.is_action_pressed("any_keyboard_input"):
		if CONTROLLER_USED:
			CONTROLLER_USED = false
			emit_signal("input_device_changed")
