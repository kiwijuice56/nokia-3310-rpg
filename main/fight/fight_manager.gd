class_name FightManager
extends Node

@export var encounters: Array[Array]

signal accepted

var index: int = 0

func _ready() -> void:
	%FightMenu.visible = false
	%FightMenu.anchors_preset = Control.PRESET_FULL_RECT
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
		%OptionContainer.get_child(old_index).get("theme_override_styles/normal").bg_color = Color("#000000")
		%OptionContainer.get_child(old_index).set("theme_override_colors/font_color", Color("#879188"))
		
		%OptionContainer.get_child(index).get("theme_override_styles/normal").bg_color = Color("#879188")
		%OptionContainer.get_child(index).set("theme_override_colors/font_color", Color("#000000"))
		AudioManager.play_sound("accept", 1)
	if Input.is_action_just_pressed("accept"):
		accepted.emit()
		AudioManager.play_sound("accept", 1)

func update_info() -> void:
	%FightLifeLabel.text = "Life: %d/%d" % [Status.player_stats.life, Status.player_stats.max_life]
	%SomaLabel.text = "Soma x%d" % (0 if not "Soma" in Status.player_stats.items else Status.player_stats.items["Soma"])
	%BombLabel.text = "Bomb x%d" % (0 if not "Bomb" in Status.player_stats.items else Status.player_stats.items["Bomb"])
	%AttackLabel.text = "Attack"
	%RunLabel.text = "Run"

func fight(enemy = null) -> bool:
	update_info()
	Ref.player.can_move = false
	if Ref.dungeon.get_difficulty() == 0:
		Ref.player.can_move = true
		return false
	var encounter: Enemy = encounters[Ref.dungeon.get_difficulty()].pick_random()
	
	if enemy != null:
		encounter = enemy
	
	%FightMenu/VBoxContainer.visible = false
	%FightMenu.visible = true
	%EnemySprite.visible = true
	%EnemySprite.texture = encounter.sprite
	%EnemySprite/AnimationPlayer.play(encounter.anim)
	AudioManager.play_sound("negative1", 2)
	
	var timer = get_tree().create_timer(1.0)
	await timer.timeout
	
	%FightMenu/VBoxContainer.visible = true
	%OptionContainer.visible = false
	%InfoLabel.visible = true
	%InfoLabel.text = encounter.encounter_description
	
	timer = get_tree().create_timer(2.0)
	await timer.timeout
	
	var ran: bool = false
	encounter = encounter.duplicate()
	while encounter.life > 0 and Status.player_stats.life > 0:
		update_info()
		
		%OptionContainer.get_child(index).get("theme_override_styles/normal").bg_color = Color("#879188")
		%OptionContainer.get_child(index).set("theme_override_colors/font_color", Color("#000000"))
		
		%OptionContainer.visible = true
		%InfoLabel.visible = false
		set_process_input(true)
		await accepted
		set_process_input(false)
		
		%OptionContainer.visible = false
		%InfoLabel.visible = true
		if index == 0:
			var damage: int = (1.5 if "Hex" in Status.player_stats.items else 1.0) * Status.player_stats.strength
			if "Sol" in Status.player_stats.items:
				damage *= 2
			encounter.life -= damage
			%InfoLabel.text = "You deal %d damage!" % damage
			%EnemySprite/AnimationPlayer.play("hurt")
			AudioManager.play_sound("bomb", 2)
			await %EnemySprite/AnimationPlayer.animation_finished
			timer = get_tree().create_timer(0.6)
			await timer.timeout
		elif index == 1:
			%InfoLabel.text = "You try to run away..."
			AudioManager.play_sound("run", 2)
			timer = get_tree().create_timer(1.2)
			await timer.timeout
			
			ran = randf() < (0.3 + Status.player_stats.dexterity / 16.0)
			if not ran:
				%InfoLabel.text = "... but you were too slow!"
				AudioManager.play_sound("negative1", 2)
				timer = get_tree().create_timer(1.5)
				await timer.timeout
			else:
				break
		elif index == 2 and Status.player_stats.items["Soma"] > 0:
			Status.player_stats.items["Soma"] -= 1
			Status.player_stats.life = Status.player_stats.max_life
			update_info()
			%InfoLabel.text = "You fully recover!" 
			AudioManager.play_sound("heal", 2)
			timer = get_tree().create_timer(1.2)
			await timer.timeout
		elif index == 3 and Status.player_stats.items["Bomb"] > 0:
			var damage: int =  (3.0 if "Hex" in Status.player_stats.items else 2.0) * Status.player_stats.strength
			if "Sol" in Status.player_stats.items:
				damage *= 2
			Status.player_stats.items["Bomb"] -= 1
			encounter.life -= damage
			%InfoLabel.text = "You threw a bomb and deal %d damage!" % damage
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
		else:
			AudioManager.play_sound("bump", 0)
			continue
		
		var salvage: bool = randf() < (Status.player_stats.dexterity / 32.0)
		if (index == 2 or index == 3) and salvage:
			if index == 3:
				Status.player_stats.items["Bomb"] += 1
			if index == 2:
				Status.player_stats.items["Soma"] += 1
			%InfoLabel.text = "You salvage the item thanks to your Dexterity!"
			AudioManager.play_sound("good1", 2)
			timer = get_tree().create_timer(1.5)
			await timer.timeout
		
		if encounter.life <= 0 or ran:
			break
		
		%InfoLabel.visible = true
		var damage: int = encounter.strength * (0.5 if "Orb" in Status.player_stats.items else 1.0)
		Status.player_stats.life -= damage
		update_info()
		%InfoLabel.text = "It deals %d damage!" % damage
		%EnemySprite/AnimationPlayer.play("attack")
		
		AudioManager.play_sound("attack", 2)
		await %EnemySprite/AnimationPlayer.animation_finished
		timer = get_tree().create_timer(0.6)
		await timer.timeout
		%EnemySprite/AnimationPlayer.play(encounter.anim)
	
	var won: bool = false
	if encounter.life <= 0:
		%EnemySprite.visible = false
		won = true
	if Status.player_stats.life <= 0:
		won = false
		AudioManager.play_sound("hit5", 2)
		%InfoLabel.text = "You die..."
		
		Ref.player.reset()
		timer = get_tree().create_timer(1.5)
		await timer.timeout
		
		var gold_lost: int = round(Status.player_stats.items["Gold"] * 0.35)
		Status.player_stats.items["Gold"] -= gold_lost
		if Status.player_stats.items["Gold"] < 0:
			Status.player_stats.items["Gold"] = 0
		
		%InfoLabel.text = "You lose %d Gold." % gold_lost
		timer = get_tree().create_timer(1.5)
		await timer.timeout
		
		Ref.ui.get_node("Death").visible = true
		timer = get_tree().create_timer(2.5)
		await timer.timeout
		Ref.ui.get_node("Death").visible = false
	else:
		
		%InfoLabel.text = "... and you succeed!" if ran else "The creature stopped breathing!"
		AudioManager.play_sound("win", 4)
		
		timer = get_tree().create_timer(1.5)
		await timer.timeout
		
		if not ran:
			%InfoLabel.text = "In its corpse, you find %d %s" % [encounter.drop_count, encounter.drop]
			timer = get_tree().create_timer(1.5)
			await timer.timeout
			Status.player_stats.items[encounter.drop] += encounter.drop_count 
		else:
			won = false
	%FightMenu.visible = false
	Ref.player.can_move = true
	
	return won
