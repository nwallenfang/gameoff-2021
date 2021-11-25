extends AbstractState

export var FOLLOW_ACCELERATION := 140000.0
export var STOP_DISTANCE := 30.0
export var PLAYER_DETECT_DISTANCE := 120.0

# should be a global position to make sure
var target_position: Vector2
var done = false
signal movement_completed
var first_time_following = true
var stop_when_player_near = false
var distance_to_player


func process(delta: float, first_time_entering: bool):
	if first_time_entering:
		parent.levitation_player.play("up")
		first_time_following = true
		done = false
	elif not done and not parent.levitation_player.is_playing():
		if first_time_following:
			parent.animation_player.play("fly_move")
			first_time_following = false
		
		if stop_when_player_near:
			distance_to_player = parent.global_position.distance_to(GameStatus.CURRENT_PLAYER.global_position)
			if distance_to_player < PLAYER_DETECT_DISTANCE:
				parent.animation_state.travel("Idle")
				emit_signal("movement_completed")
				done = true
				return
		
			
		var distance_vec := (target_position - parent.global_position) as Vector2
		
		if distance_vec.length() < STOP_DISTANCE:
			state_machine.enabled = false
			parent.animation_player.play("fly_idle")
			parent.set_facing_direction(distance_vec)
			emit_signal("movement_completed")
			done = true
			return
		parent.animation_player.play("fly_move")
	
		parent.add_acceleration(delta * FOLLOW_ACCELERATION * distance_vec.normalized())
