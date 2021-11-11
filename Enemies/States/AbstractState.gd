extends Node

class_name AbstractState

# overwrite this if you want to
export var RELATIVE_TRANSITION_CHANCE: float = 1.0

onready var state_machine
onready var State: Dictionary
onready var parent = get_parent().get_parent()


func _ready() -> void:
	state_machine = get_parent()
	State = state_machine.State  
	# TODO  print warning if not child of state machine
	
func process(delta: float, first_time_entering: bool) -> void:
	# implement this
	pass
