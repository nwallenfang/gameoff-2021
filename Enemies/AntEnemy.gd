extends SlideMover


enum State {
	CHASE_PLAYER, IDLE, SPRINT, SHOOT_STUFF
}

export var IDLE_TIME := 1

const idle_transition_chance = {
	State.IDLE: 0.0,
	State.CHASE_PLAYER: 0.0,
	State.SHOOT_STUFF: 0.05,
	State.SPRINT: 0.95
}

# will be true for the first frame you are in a new state
var first_time_entering = true
var state = State.IDLE


func _ready() -> void:
	if OS.is_debug_build():
		$StateLabel.visible = true
		$Line2D.visible = true


func _on_Hurtbox_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	# parent should either be a projectile, poison mist or another weapon
	if parent is Projectile:
		var attack := parent as Projectile
		$EnemyStats.health -= attack.damage
		add_velocity(attack.knockback_vector())
	if parent is PlayerCloseCombat:
		var attack := parent as PlayerCloseCombat
		$EnemyStats.health -= attack.damage
		add_velocity(attack.knockback_vector())
	if parent is PoisonFragment:
		var attack := parent as PoisonFragment
		$EnemyStats.health -= attack.damage


func _on_EnemyStats_health_changed() -> void:
	$Healthbar.health = $EnemyStats.health


func _on_EnemyStats_health_zero() -> void:
	# TODO I would like not to kick around dead bodies quite as hard..
	set_velocity(Vector2.ZERO)
	$AnimationPlayer.play("dying")  # queue_free is called at the end of this

func match_state(delta):
	$StateLabel.text = State.keys()[state]
	var this_was_the_first_time = first_time_entering
	match state:
		State.IDLE:
			state_idle()
		State.SPRINT:
			state_sprint(delta)
		State.CHASE_PLAYER:
			state_chase_player()
		State.SHOOT_STUFF:
			state_shoot_stuff()
	
	if this_was_the_first_time:
		first_time_entering = false

# variables local to state sprint, if another enemy needs this skill
# you could take these variables and the method to a new script SprintAttack
var distance_to_player
var target_point
const MAX_SPRINT_DISTANCE := 500
export var SPRINT_VELOCITY := 400

func begin_sprinting(delta: float) -> void:
	var direction = $Line2D.points[1].angle() + PI/2
	distance_to_player = ($Line2D.points[1] - $Line2D.points[0]).length()
	
	# 1. if this enemy is too far from the player, don't sprint
	if distance_to_player > MAX_SPRINT_DISTANCE:
		transition_to(State.IDLE)
		return
	
	# 2. see if there is line of sight towards the player
	# cast a ray between Enemy and player for this
	var space_state = get_world_2d().direct_space_state
	var ray_result = space_state.intersect_ray(self.global_position, GameStatus.CURRENT_PLAYER.global_position)
	
	if not ray_result.empty():
		# there is some object between you and the player
		# maybe this is not the time to go full on sprinting
		transition_to(State.IDLE)
		return
	
	# now we know there is direct line of sight and the player is close
	# TODO wait for a while first and signify to the player that something
	# gnarly is about to happen (TODO show attention mark above enemy)
	# TODO maybe even play a slight sound
	target_point = $Line2D.points[1] + position
	
	$SprintMovementTween.interpolate_property(self, "position", position, target_point, 1,
	Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	$SprintMovementTween.start()
	
	# TODO add soft collisions

func state_sprint(delta):
	if first_time_entering:
		begin_sprinting(delta)
	else:
		# execute the actual sprinting movement
		# since we know there is clear line of sight there won't be collisions
		# no reason to use Godot physics to simulate this movement
		
		# we can try to use a tween to interpolate this movement for now
		# the only question is whether collisions with the player mid-movement
		# (and soft-collisions) work out of the box
		pass
		
	
func state_chase_player():
	pass
	
func state_shoot_stuff():
	if not first_time_entering:  # with the call_deferred this shouldn't be needed
		return

	# for now either shoot a cone in the player direction or shoot radial
	var direction = $Line2D.points[1].angle() + PI/2
	var random_flip := randi() % 2
	if random_flip:
		$EnemyProjectileSpawner.spawn_cone_projectile_volley(direction, 30, 5, 0.2, 3)
	else:
		$EnemyProjectileSpawner.spawn_radial_projectiles(16)

	# TODO shooting stuff should be depending on distance to player
	# if too far from the player, don't shoot at all but enter another state instead
	
	# go back to being idle in the next frame
	transition_to(State.IDLE)

	
func transition_to(new_state):
	first_time_entering = true
	state = new_state
	
func transition_to_random_state():
	# another day of being an idle enemy ant
	# who knows what the day may bring
	# maybe shoot some stuff
	# maybe even go for a little walk
	# let the dice decide
	var rand := randf()  # random seed
	var psum: float = 0.0 # sum of probabilities that were already checked in for loop
	
	# idea: if the random number between 0 and 1 is smaller than the 
	# states up to some point, enter the state
	# else go on. For this the state probabilities' sum has to be 1
	for new_state in State.values():
		psum += idle_transition_chance[new_state]
		if rand <= psum:
			transition_to(new_state)
			break
		# random seed doesn't fit new state, go next
	
	
func state_idle():
	if $IdleTimer.is_stopped():
		$IdleTimer.start(1)
	
	

func _physics_process(delta: float) -> void:
	# call for handling knockback
	accelerate_and_move(delta)
	$Line2D.points[1] = $ScentRay.get_player_scent_position() - position
	
	match_state(delta)


func _on_IdleTimer_timeout() -> void:
	transition_to_random_state()
	$IdleTimer.stop()
