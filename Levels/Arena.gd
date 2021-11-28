extends Node2D

onready var cordy
onready var thorn_shooter = $YSort/PreArena/ThornShooter
onready var pre_arena_pho = $YSort/PreArena/Phoridae
onready var shot_caller = $YSort/ShotcallerAnt as AntEnemy
onready var shot_caller_speech = $YSort/ShotcallerAnt/SpeechBubble as SpeechBubble
onready var w1_ant1 = $YSort/Wave1Enemies/AntEnemy1
onready var w1_ant2 = $YSort/Wave1Enemies/AntEnemy2
onready var w1_ant3 = $YSort/Wave1Enemies/AntEnemy3
onready var w1_ant4 = $YSort/Wave1Enemies/AntEnemy4

onready var gate = $Positions/GatePass.global_position

# ants should come later once 2 phos have been killed
onready var w2_ant1 = $YSort/Wave2Enemies/AntEnemy1
onready var w2_ant2 = $YSort/Wave2Enemies/AntEnemy2
onready var w2_pho1 = $YSort/Wave2Enemies/Phoridae1
onready var w2_pho2 = $YSort/Wave2Enemies/Phoridae2
onready var w2_pho3 = $YSort/Wave2Enemies/Phoridae3
onready var w2_pho4 = $YSort/Wave2Enemies/Phoridae4
onready var w2_thrower = $YSort/Wave2Enemies/AntThrower
onready var w2_raphid1 = $YSort/Wave2Enemies/RedAphid1
onready var w2_raphid2 = $YSort/Wave2Enemies/RedAphid2
onready var w2_raphid3 = $YSort/Wave2Enemies/RedAphid3


var enemies_killed_baseline: int

func _ready():
	GameStatus.CURRENT_ACT = self
	GameStatus.CURRENT_YSORT = $YSort
	GameStatus.CURRENT_UI = $UI
	GameStatus.CURRENT_PLAYER = $YSort/Player
	GameStatus.CURRENT_CAMERA = $ScriptedCamera
	GameStatus.CURRENT_CAM_REMOTE = $YSort/Player/CamRemote
	GameStatus.CURRENT_HEALTH = GameStatus.PLAYER_MAX_HEALTH
	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.SHOOT_ENABLED = false
	GameStatus.DASH_ENABLED = true
	GameStatus.AIMER_VISIBLE = true
	GameStatus.HEALTH_VISIBLE = true
	GameStatus.MOUSE_CAPTURE = true
	GameStatus.BOSS_HEALTH_VISIBLE = false
	
	pre_arena_pho.get_node("StateMachine").stop()
	
	# phos invisible till wave 2
	w2_pho1.visible = false
	w2_pho2.visible = false
	w2_pho3.visible = false
	w2_pho4.visible = false
	w2_pho1.very_aggressive = true
	w2_pho2.very_aggressive = true
	w2_pho3.very_aggressive = true
	w2_pho4.very_aggressive = true
	w2_pho1.set_facing_direction(Vector2.LEFT)
	w2_pho2.set_facing_direction(Vector2.LEFT)
	w2_pho3.set_facing_direction(Vector2.LEFT)
	w2_pho4.set_facing_direction(Vector2.LEFT)
	
	CheckpointManager.connect("player_respawned", self, "died_in_arena")
	
	# what should definitely be activated in the Arena?	
	cordy = GameStatus.CURRENT_UI.get_node("ShroomUI") as Cordy
	cordy.show()
	cordy.set_eyes("idle")
		
	w2_raphid1.visible = true
	w2_raphid2.visible = true
	w2_raphid3.visible = true
	w2_thrower.visible = true
	
	var thrower_behavior = {
		"Chase": 1.0,
		"SimpleShoot": 1.0,
		"ThrowAphid": 0.6,
		"Sprint": 0.0,
	}
	w2_thrower.set_behavior(thrower_behavior)
	
	GameEvents.connect("arena_wave1", self, "wave1")
	GameEvents.connect("arena_wave2", self, "wave2")
	GameEvents.connect("shroom_to_shroom_talk", self, "shroom_to_shroom_talk")
	GameEvents.connect("learn_shoot", self, "learn_shoot")
	GameEvents.connect("trigger_thorn_shooter", self, "trigger_thorn_shooter")
	GameEvents.connect("thorn_camera", self, "thorn_camera")
	GameEvents.connect("trigger_phoridae", self, "trigger_phoridae")


func learn_shoot():
	cordy.say_bottom("I have prepared a new skill for you to use.")
	GameStatus.SHOOT_ENABLED = true
	yield(cordy, "speech_done")
	cordy.say("Learn to master it and nothing can get in our way.")
	
func trigger_thorn_shooter():
	var shooter_behavior = {
		"Chase": 0.0,
		"SimpleShoot": 1.0,
		"Sprint": 0.0
	}
	var lower_health := 14 # default is 20
	thorn_shooter.knockbackable = false
	thorn_shooter.set_behavior(shooter_behavior)
	thorn_shooter.get_node("EnemyStats").set_max_health(lower_health)
	thorn_shooter.trigger()


func last_enemy_ready_wave1():
	w1_ant1.trigger()
	w1_ant2.trigger()
	w1_ant3.trigger()
	w1_ant4.trigger()
	
func last_enemy_ready_wave2():
	w2_pho1.trigger()
	w2_pho2.trigger()

func wave1():
	GameStatus.MOVE_ENABLED = false
	GameStatus.SHOOT_ENABLED = false
	GameStatus.DASH_ENABLED = false
	GameStatus.SPRAY_ENABLED = false
	GameStatus.AIMER_VISIBLE = false

	$ScriptedCamera.follow(shot_caller, 1.8)
	yield($ScriptedCamera, "follow_target_reached")
	shot_caller_speech.set_text("Welcome to the arena!", 1.5)
	yield(shot_caller_speech, "dialog_completed")
	shot_caller_speech.set_text("We've been expecting you, scoundrel.", 1.5)
	yield(shot_caller_speech, "dialog_completed")
	shot_caller_speech.set_text("There is an extraordinary cast of brave soldiers waiting..", 0.6) 
	yield(shot_caller_speech, "dialog_completed")
	shot_caller_speech.set_text("..who will ensure your inevitable downfall!", 0.9)
	yield(shot_caller_speech, "dialog_completed")

	shot_caller_speech.set_text("Enter the Arena, fellow ants!", 0.6)	
	yield(shot_caller_speech, "dialog_completed")
	$ScriptedCamera.stop_following()
	$ScriptedCamera.slide_away_to($Positions/GatePass.global_position, 1.8)
	yield($ScriptedCamera, "slide_finished")
	cordy.set_eyes("bored")
	cordy.say("Yes! What a perfect occasion to try out your newfound abilities.")

	w1_ant3.connect("follow_completed", self, "last_enemy_ready_wave1")
	w1_ant1.follow_path_array_then_fight([gate, $Positions/Wave11.global_position])
	w1_ant2.follow_path_array_then_fight([gate, $Positions/Wave11.global_position, $Positions/Wave12.global_position])
	w1_ant3.follow_path_array_then_fight([gate, $Positions/Wave14.global_position, $Positions/Wave13.global_position])
	w1_ant4.follow_path_array_then_fight([gate, $Positions/Wave14.global_position])

	yield(get_tree().create_timer(3.8), "timeout")
	cordy.set_eyes("idle")
	$ScriptedCamera.back_to_player(1.0)

	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.SHOOT_ENABLED = true
	GameStatus.DASH_ENABLED = true
	GameStatus.AIMER_VISIBLE = true

#	print("wave2 once ", GameEvents.count("enemy_died") + 4, "have been killed, you're at ", GameEvents.count("enemy_died"))
	GameEvents.connect_to_event_count('enemy_died', GameEvents.count("enemy_died") + 4, self, "wave2")


	# fight fight fight

	
func wave2():
	w2_pho1.visible = true
	w2_pho2.visible = true

	yield(get_tree().create_timer(0.6), "timeout")
	GameStatus.MOVE_ENABLED = false
	GameStatus.SPRAY_ENABLED = false
	GameStatus.SHOOT_ENABLED = false
	GameStatus.DASH_ENABLED = false
	GameStatus.AIMER_VISIBLE = false
	$ScriptedCamera.slide_to_object(shot_caller, 1.8)
	yield($ScriptedCamera, "slide_finished")
	shot_caller_speech.set_text("Well.. let's consider that warm-up done..", 1.0)
	yield(shot_caller_speech, "dialog_completed")
	cordy.say("Pfft")
	cordy.set_eyes("bored")
	shot_caller_speech.set_text("Time to bring on the real deal, the mighty fine Phoridae!", 1.5)
	yield(shot_caller_speech, "dialog_completed")
	shot_caller_speech.set_text("No mere worker could dodge their magic shots.", 1.5)
	yield(shot_caller_speech, "dialog_completed")
	cordy.set_eyes("idle")
	cordy.say("Ignore him,rules for workers don't apply to you anymore.")

	# camera again to gate
	$ScriptedCamera.slide_away_to($Positions/GatePass.global_position, 1.8)
	yield($ScriptedCamera, "slide_finished")

	# have the wave2 enemies walk in
	w2_pho1.follow_path_array_then_fight([$Positions/Wave21.global_position])
	w2_pho2.follow_path_array_then_fight([$Positions/Wave21.global_position])

	yield(get_tree().create_timer(3.4), "timeout")

	$ScriptedCamera.back_to_player(1.0)
	yield($ScriptedCamera, "slide_finished")

	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.SHOOT_ENABLED = true
	GameStatus.DASH_ENABLED = true
	GameStatus.AIMER_VISIBLE = true

	# wait for wave 2 to have died

	print("wave2_backup once ", GameEvents.count("enemy_died") + 2, "have been killed, you're at ", GameEvents.count("enemy_died"))
	GameEvents.connect_to_event_count('enemy_died', GameEvents.count("enemy_died") + 2, self, "wave2_backup")	



func wave2_backup():
	w2_raphid1.visible = true
	w2_raphid2.visible = true
	w2_raphid3.visible = true
	w2_raphid1.get_node("StateMachine").start()
	w2_raphid2.get_node("StateMachine").start()
	w2_raphid3.get_node("StateMachine").start()
	w2_thrower.visible = true
	w2_pho3.visible = true
	w2_pho4.visible = true
	cordy.set_eyes("idle")
	cordy.say("Careful, there are more enemies coming.")
	w2_pho3.follow_path_array_then_fight([$Positions/Wave21.global_position])
	w2_pho4.follow_path_array_then_fight([$Positions/Wave21.global_position])
	w2_thrower.follow_path_array_then_fight([$Positions/Wave21.global_position])
	print("DONE once ", GameEvents.count("enemy_died") + 6, "have been killed, you're at ", GameEvents.count("enemy_died"))
	GameEvents.connect_to_event_count('enemy_died', GameEvents.count("enemy_died") + 6, self, "after_wave2")

func after_wave2():
	$ScriptedCamera.follow(shot_caller, 1.8)
	yield($ScriptedCamera, "follow_target_reached")
	shot_caller_speech.set_text("That's it for now! Thanks for playing!", 1.0)
	cordy.set_eyes("bored")
	cordy.say("Nooo, I want more destruction!")
	yield(shot_caller_speech, "dialog_completed")
	shot_caller_speech.set_text("Be sure to give us some feedback!", 1.0)
	yield(shot_caller_speech, "dialog_completed")
	$ScriptedCamera.stop_following()
	$ScriptedCamera.back_to_player()
	yield($ScriptedCamera, "slide_finished")
	

func reset():
	pass


func shroom_to_shroom_talk(speech_position: Vector2):
	$OtherShroomSpeech.global_position = speech_position
	$OtherShroomSpeech.set_text("Yo Cordy!", 1.0)
	yield($OtherShroomSpeech, "dialog_completed")
	cordy.say("Yo Fred, haven't seen you up here in so long!", 1.5)
	yield(cordy, "speech_done")
	$OtherShroomSpeech.set_text("Uh-huh..", 0.6)
	yield($OtherShroomSpeech, "dialog_completed")
	cordy.set_eyes("happy")
	cordy.say("What have you been up to?")
	yield(cordy, "speech_done")
	$OtherShroomSpeech.set_text("You know, expanding my mycelium..", 0.8)
	yield($OtherShroomSpeech, "dialog_completed")
	$OtherShroomSpeech.set_text("Sharing some spores..", 0.6)
	cordy.set_eyes("bored")
	yield($OtherShroomSpeech, "dialog_completed")
	$OtherShroomSpeech.set_text("Being intimate with some oak roots..", 1.2)
	yield($OtherShroomSpeech, "dialog_completed")
	cordy.set_eyes("bored")
	cordy.say("Uhmmm... alright, bye then!")
	yield(get_tree().create_timer(2.5), "timeout")
	cordy.set_eyes("idle")
	cordy.say_right("The world of fungi can be so small. And weird.")

func died_in_arena():
	# wait for player to have actually respawned
	cordy.set_eyes("angry")
	cordy.say("Weak, you must do better than this.")
	yield(cordy, "speech_done")
	cordy.set_eyes("idle")

func _on_Wave1TriggerZone_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("arena_wave1")

func _process(delta):
	if Input.is_action_just_pressed("kill_all_enemies"):
		print("kill all")
		for child in $YSort/Wave1Enemies.get_children():
			if child is AntEnemy:
				var ant_enemy = child as AntEnemy
				if ant_enemy.state_machine.enabled:
					ant_enemy.get_node("EnemyStats").health = 0
			if child is Phoridae:
				var pho = child as Phoridae
				if pho.get_node("StateMachine").enabled:
					pho.get_node("PhoridaeStats").health = 0
		for child in $YSort/Wave2Enemies.get_children():
			if child is AntEnemy:
				var ant_enemy = child as AntEnemy
				if ant_enemy.state_machine.enabled:
					ant_enemy.get_node("EnemyStats").health = 0
			if child is Phoridae:
				var pho = child as Phoridae
				if pho.get_node("StateMachine").enabled:
					pho.get_node("PhoridaeStats").health = 0


func _on_ShroomDialogZone_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event_with_arg("shroom_to_shroom_talk", 
	$Positions/ShroomTalkPos1.global_position)

func _on_ShroomDialogZone2_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event_with_arg("shroom_to_shroom_talk", 
	$Positions/ShroomTalkPos2.global_position)


func _on_ShroomSkillTrigger_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("learn_shoot")


func _on_TriggerArea_body_entered(body: Node) -> void:
	# hard coding mess
	GameStatus.SHOOT_ENABLED = true
	# set gate
	$ArenaBlock.collision_layer = GameStatus.CURRENT_PLAYER.collision_mask
	if is_instance_valid(pre_arena_pho):
		pre_arena_pho.queue_free()


func _on_ShroomSkillTrigger2_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("trigger_thorn_shooter")


func _on_DynamicCameraTrigger_body_entered(body: Node) -> void:
	if is_instance_valid(thorn_shooter):
		GameEvents.trigger_event("thorn_camera")


func trigger_phoridae():
	pre_arena_pho.very_aggressive = true
	if is_instance_valid(pre_arena_pho):
		pre_arena_pho.get_node("StateMachine").enabled = true
		pre_arena_pho.trigger()
	yield(get_tree().create_timer(0.5), "timeout")
	cordy.set_eyes("angry")
	cordy.say("Looks like they've hired new flying defendants.")

	yield(cordy, "speech_done")
	cordy.set_eyes("idle")


func thorn_camera():
	cordy.set_eyes("happy")
	cordy.say_bottom("Now you can stop these thorny shenanigans.")
	$Detector/DynamicCameraTrigger/DynamicPlayerCam.target = thorn_shooter
	$ScriptedCamera.follow($Detector/DynamicCameraTrigger/DynamicPlayerCam)
	
	yield(thorn_shooter, "died")
	cordy.set_eyes("happy")
	cordy.say_bottom("Nice, that's all there's to it.")

	$ScriptedCamera.back_to_player()

func _on_DynamicCameraTrigger_body_exited(body: Node) -> void:
	if is_instance_valid(thorn_shooter):
		$ScriptedCamera.back_to_player()


func _on_PrePhoTrigger_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("trigger_phoridae")
