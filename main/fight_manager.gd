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

func update_info() -> void:
	%FightLifeLabel.text = "Life: %d/%d" % [Status.player_stats.life, Status.player_stats.max_life]
	%SomaLabel.text = "Soma x%d" % (0 if not "Soma" in Status.player_stats.items else Status.player_stats.items["Soma"])
	%BombLabel.text = "Bomb x%d" % (0 if not "Bomb" in Status.player_stats.items else Status.player_stats.items["Bomb"])
	%AttackLabel.text = "Attack"
	%RunLabel.text = "Run"

func fight() -> void:
	update_info()
	Ref.player.can_move = false
	var encounter: Enemy = encounters[Ref.dungeon.get_difficulty()].pick_random()
	%FightMenu/VBoxContainer.visible = false
	%FightMenu.visible = true
	%EnemySprite.visible = true
	%EnemySprite.texture = encounter.sprite
	%EnemySprite/AnimationPlayer.play("idle")
	AudioManager.play_sound("negative1", 2)
	
	var timer = get_tree().create_timer(1.0)
	await timer.timeout
	
	AudioManager.play_sound("battle", 0)
	
	%FightMenu/VBoxContainer.visible = true
	%OptionContainer.visible = false
	%InfoLabel.visible = true
	%InfoLabel.text = "A %s blocks your path." % encounter.display_name
	
	timer = get_tree().create_timer(3.0)
	await timer.timeout
	
	encounter = encounter.duplicate()
	while encounter.life > 0 and Status.player_stats.life > 0:
		update_info()
		index = 0
		%AttackLabel.text += "<"
		%OptionContainer.visible = true
		%InfoLabel.visible = false
		set_process_input(true)
		await accepted
		
		%OptionContainer.visible = false
		%InfoLabel.visible = true
		if index == 0:
			encounter.life -= Status.player_stats.strength
			%InfoLabel.text = "You dealt %d damage!" % Status.player_stats.strength
			%EnemySprite/AnimationPlayer.play("hurt")
			AudioManager.play_sound("bomb", 2)
			await %EnemySprite/AnimationPlayer.animation_finished
			timer = get_tree().create_timer(0.6)
			await timer.timeout
		if index == 1:
			pass
		if index == 2 and Status.player_stats.items["Soma"] > 0:
			Status.player_stats.items["Soma"] -= 1
			pass
		if index == 3 and Status.player_stats.items["Bomb"] > 0:
			Status.player_stats.items["Bomb"] -= 1
			encounter.life -= Status.player_stats.strength * 2
			%InfoLabel.text = "You threw a bomb and dealt %d damage!" % (Status.player_stats.strength * 2)
			%EnemySprite/AnimationPlayer.play("hurt")
			AudioManager.play_sound("bomb", 2)
			timer = get_tree().create_timer(0.4)
			await timer.timeout
			%EnemySprite/AnimationPlayer.stop()
			%EnemySprite/AnimationPlayer.play("bomb")
			AudioManager.play_sound("bomb", 3)
			await %EnemySprite/AnimationPlayer.animation_finished
			timer = get_tree().create_timer(0.6)
			await timer.timeout
		
		
		if encounter.life <= 0:
			break
		%EnemySprite/AnimationPlayer.play("idle")
		
		%InfoLabel.visible = true
		Status.player_stats.life -= encounter.strength
		update_info()
		%InfoLabel.text = "%s dealt %d damage!" % [encounter.display_name, encounter.strength]
		%EnemySprite/AnimationPlayer.play("attack")
		AudioManager.play_sound("attack", 2)
		await %EnemySprite/AnimationPlayer.animation_finished
		timer = get_tree().create_timer(0.6)
		await timer.timeout
	
	if encounter.life <= 0:
		%EnemySprite.visible = false
	
	AudioManager.stop_sound("battle")
	%InfoLabel.text = "The creature stopped breathing!"
	AudioManager.play_sound("win", 4)
	
	timer = get_tree().create_timer(1.5)
	await timer.timeout
	
	%InfoLabel.text = "In its corpse, you find %d %s" % [encounter.drop_count, encounter.drop]
	timer = get_tree().create_timer(1.5)
	await timer.timeout
	
	Status.player_stats.items[encounter.drop] += encounter.drop_count 
	
	%FightMenu.visible = false
	Ref.player.can_move = true
