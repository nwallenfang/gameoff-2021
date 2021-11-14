extends Camera2D
class_name ScriptedCamera

var on_player := true
var follow_target: Node2D = null
var following := false

signal slide_finished
signal back_at_player
signal follow_target_reached

func follow(obj: Node2D, time: float = 2.0) -> void:
	slide_to_object(obj, time)
	follow_target = obj

func stop_following() -> void:
	following = false
	follow_target = null

func slide_to_object(obj: Node2D, time: float = 2.0) -> void:
	slide_away_to(obj.global_position, time)

func slide_away_to(pos: Vector2, time: float = 2.0) -> void:
	on_player = false
	GameStatus.CURRENT_CAM_REMOTE.update_position = false
	drag_margin_h_enabled = false
	drag_margin_v_enabled = false
	__slide_to(pos, time)

func __slide_to(pos: Vector2, time: float = 2.0) -> void:
	print(pos)
	print("---------")
	print(global_position)
	$Tween.remove_all()
	$Tween.interpolate_property(self, "position", position, pos, time,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()

func back_to_player(time: float = 2.0) -> void:
	on_player = true
	__slide_to(GameStatus.CURRENT_PLAYER.global_position, time)

func _on_Tween_tween_all_completed() -> void:
	print(position)
	print(global_position)
	emit_signal("slide_finished")
	if on_player:
		GameStatus.CURRENT_CAM_REMOTE.update_position = true
		drag_margin_h_enabled = true
		drag_margin_v_enabled = true
		emit_signal("back_at_player")
	if follow_target != null:
		following = true
		emit_signal("follow_target_reached")

func _process(delta: float) -> void:
	if following:
		global_position = follow_target.global_position
