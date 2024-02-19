class_name Player
extends Sprite2D

@export var move_time: float = 0.11

var dir: Vector2 
var move_tween: Tween
var pressed_moves: Array[String] = []
var just_bumped: bool = false
var can_move: bool = true
var move_map: Dictionary = {
	"ui_left": Vector2(-1, 0), 
	"ui_right": Vector2(1, 0),
	"ui_up": Vector2(0, -1),
	"ui_down": Vector2(0, 1),
}

func _process(_delta: float) -> void:
	if not can_move:
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		if not $RayCast2D.is_colliding():
			return
		var collider = $RayCast2D.get_collider()
		if not collider is Interactable:
			return
		collider.interact(self)
		return
	
	dir = Vector2()
	
	for move in move_map:
		if Input.is_action_pressed(move):
			if not move in pressed_moves:
				pressed_moves.append(move)
	var still_pressed: Array[String] = []
	for move in pressed_moves:
		if Input.is_action_pressed(move):
			still_pressed.append(move)
	pressed_moves = still_pressed
	
	if is_instance_valid(move_tween) and move_tween.is_running():
		return
	
	if len(pressed_moves) > 0:
		dir = move_map[pressed_moves[len(pressed_moves) - 1]]
		slide()

func slide() -> void:
	$RayCast2D.target_position = dir * 5.5
	$RayCast2D.force_raycast_update()
	if $RayCast2D.is_colliding():
		if not just_bumped and not AudioManager.is_playing("bump"):
			just_bumped = true
			# kinda annoying...
			# AudioManager.play_sound("bump", 1)
	else:
		just_bumped = false
		$AnimationPlayer.stop()
		$AnimationPlayer.play("walk")
		move_tween = get_tree().create_tween()
		move_tween.tween_property(self, "position", position + dir * 6, move_time)
