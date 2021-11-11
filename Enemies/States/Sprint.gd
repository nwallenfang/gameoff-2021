extends AbstractState

const MAX_SPRINT_DISTANCE := 400
export var SPRINT_VELOCITY := 110 # px/s (Tween property)
export var SPRINT_DELAY := 0.4


func _ready():
	# parent has to be a physical body for this state
	self.parent = self.parent as PhysicsMover
	if not self.parent:
		# TODO print warning
		print("!")
		pass



func begin_sprinting(delta: float):
	# TODO if you want to make this more general/  transfer to another enemy
	# give Sprint State node a Line2D child and use that instead
	# make the child line2d point to a remote position or smth
	var line2d = parent.get_node("Line2D")
	var direction = line2d.points[1].angle() + PI/2
	var distance_to_player = (line2d.points[1] - line2d.points[0]).length()
	
	# 1. if this enemy is too far from the player, don't sprint
	if distance_to_player > MAX_SPRINT_DISTANCE:
		state_machine.transition_to("Idle")
		return
	
	# 2. see if there is line of sight towards the player
	# cast a ray between Enemy and player for this
	var space_state = self.parent.get_world_2d().direct_space_state
	var ray_result = space_state.intersect_ray(self.global_position, GameStatus.CURRENT_PLAYER.global_position)
	
	if not ray_result.empty():
		# there is some object between you and the player
		# maybe this is not the time to go full on sprinting
		state_machine.transition_to("Idle")
		return 

	# warn the player by showing '!'
	$SprintWarning.show()
	# now we know there is direct line of sight and the player is close
	# execute the actual sprinting movement
	# since we know there is clear line of sight there won't be collisions
	# no reason to use Godot physics to simulate this movement
	# instead use a tween to interpolate this movement for now
	# prepare the tween for later 
	# TODO randomize 0.8 - 1.2 player position
#	var target_point = $Line2D.points[1] + position
	var target_point = parent.position + MAX_SPRINT_DISTANCE * Vector2.UP.rotated(direction)
	# duration should be independent from distance_to_player
	var duration = 0.68
	
	# TODO polish this
	$SprintMovementTween.reset_all()
	$SprintMovementTween.interpolate_property(parent, "position", parent.position, target_point, duration,
	Tween.TRANS_LINEAR)

	# TODO maybe add sprite movement perpendicularily to the movement direction in the tween
	
	# add timer, once this timer has finished, start the Tween movement
	$SprintDelayTimer.start(SPRINT_DELAY)

func process(delta: float, first_time_entering: bool):
	if first_time_entering:
		begin_sprinting(delta)
	else:
		if not $SprintDelayTimer.is_stopped():  # currently waiting to sprint
			yield($SprintDelayTimer, "timeout")
			# sprint delay is over, start actually moving
			$SprintMovementTween.start()
			$SprintWarning.hide()
		elif $SprintMovementTween.is_active():  # currently sprinting
			# if already sprinting, wait for the movement to complete
			parent.get_node("AnimationPlayer").play("sprinting")
			yield($SprintMovementTween, "tween_all_completed")
			# then go back to being idle
			state_machine.transition_to("Idle")
		else:
			# if not sprinting and having been here before, go back to being idle
			# this branch should actually not be entered, it's just to make sure
			state_machine.transition_to("Idle")