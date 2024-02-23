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

@export var encounter_chance: float = 0.02
@export var encounter_grace: int = 18
var steps: int = 0

func check_stats() -> void:
	AudioManager.play_sound("accept", 2)
	await Ref.statbox.trans_in()
	await Ref.statbox.open()
	await Ref.statbox.trans_out()
	can_move = true

func check_items() -> void:
	AudioManager.play_sound("accept", 2)
	var items: Array[String] = []
	var vals: Array[String] = []
	# Render them in an order I like:)
	for item in ["Gold", "Soma", "Bomb", "Corpse", "Kila", "Cross", "Brain", "Orb"]:
		if item in Status.player_stats.items:
			items.append(item + ":")
			vals.append(str(Status.player_stats.items[item]))
	await Ref.itembox.trans_in() 
	await Ref.itembox.open(items, vals)
	await Ref.itembox.trans_out()
	can_move = true

func _process(_delta: float) -> void:
	if not can_move:
		return
	if Input.is_action_just_pressed("stats"):
		if is_instance_valid(move_tween) and move_tween.is_running():
			return
		can_move = false
		check_stats()
		return
	if Input.is_action_just_pressed("item"):
		if is_instance_valid(move_tween) and move_tween.is_running():
			return
		can_move = false
		check_items()
		return
	if Input.is_action_just_pressed("accept"):
		if is_instance_valid(move_tween) and move_tween.is_running():
			return
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
		move_tween = get_tree().create_tween().set_parallel(true)
		move_tween.tween_property(self, "position", position + dir * 6, move_time)
		
		var new_position: Vector2 = position + dir * 6
		var top_left: Vector2 = Ref.dungeon.screen * Vector2(84, 48)
		var bottom_right: Vector2 = (Ref.dungeon.screen + Vector2(1, 1)) * Vector2(84, 48)
		var camera_offset: Vector2 = Vector2()
		if new_position.x < top_left.x:
			camera_offset = Vector2(-1, 0)
		if new_position.x > bottom_right.x:
			camera_offset = Vector2(1, 0)
		if new_position.y < top_left.y:
			camera_offset = Vector2(0, -1)
		if new_position.y > bottom_right.y:
			camera_offset = Vector2(0, 1)
		if camera_offset.length() > 0:
			move_tween.tween_property(Ref.camera, "position", Ref.camera.position + camera_offset * Vector2(84, 48), move_time * 6)
			Ref.dungeon.update_screen(Ref.dungeon.screen + camera_offset)
			can_move = false
			await move_tween.finished
			can_move = true
		
		steps += 1
		if steps >= encounter_grace and randf() < encounter_chance:
			await Ref.fight_manager.fight()
			steps = 0
