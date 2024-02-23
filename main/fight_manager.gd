class_name FightManager
extends Node

@export var encounters: Array[Array]

signal accepted

var index: int = 0

func _ready() -> void:
	%FightMenu.visible = false
	set_process_input(false)

func _input(event: InputEvent) -> void:
	var old_index: int = index
	if Input.is_action_just_pressed("ui_up"):
		index -= 2
	if Input.is_action_just_pressed("ui_down"):
		index += 2
	if Input.is_action_just_pressed("ui_left"):
		index -= 1
	if Input.is_action_just_pressed("ui_right"):
		index += 1
	if index < 0:
		index += 4
	
	index = index % 4
	
	if old_index != index:
		var old_text: String = %OptionContainer.get_child(old_index).text 
		%OptionContainer.get_child(old_index).text = old_text.substr(0, len(old_text) - 1)
		%OptionContainer.get_child(index).text += "<"
	
	if Input.is_action_just_pressed("accept"):
		accepted.emit()

func fight() -> void:
	Ref.player.can_move = false
	var encounter: Enemy = encounters[Ref.dungeon.get_difficulty()].pick_random()
	%FightMenu/VBoxContainer.visible = false
	%FightMenu.visible = true
	%EnemySprite.texture = encounter.sprite
	%EnemySprite/AnimationPlayer.play("idle")
	AudioManager.play_sound("negative1", 2)
	
	var timer = get_tree().create_timer(1.0)
	await timer.timeout
	
	%FightMenu/VBoxContainer.visible = true
	%OptionContainer.visible = false
	%InfoLabel.visible = true
	%InfoLabel.text = "A %s blocks your path." % encounter.display_name
	
	timer = get_tree().create_timer(3.0)
	await timer.timeout
	
	encounter = encounter.duplicate()
	while encounter.life > 0 and Status.player_stats.life > 0:
		%OptionContainer.visible = true
		%InfoLabel.visible = false
		set_process_input(true)
		await accepted
		
	
	
	Ref.player.can_move = true
