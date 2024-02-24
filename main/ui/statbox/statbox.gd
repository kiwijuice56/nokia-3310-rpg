class_name StatBox
extends PanelContainer

const LABEL_SIZE: int = 29

signal advanced

var choice_idx: int = 0
var sound: AudioStream 

func _ready() -> void:
	%StatLabels.text = ""
	%StatValues.text = ""
	size.y = 0
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("stats", false):
		advanced.emit()
	if event.is_action_pressed("back", false):
		advanced.emit()

func trans_in() -> void:
	%StatLabels.text = ""
	%StatValues.text = ""
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size:y", LABEL_SIZE, 0.125)
	await tween.finished
	
	var stats: Array = [
		Status.player_stats.strength,
		Status.player_stats.dexterity,
		Status.player_stats.wisdom
	]
	var lowest_stat: int = stats.min()
	var icons: Array[Resource] = [
		preload("res://main/dungeon/player/player_strength.png"),
		preload("res://main/dungeon/player/player_dex.png"),
		preload("res://main/dungeon/player/player_wis.png"),
		preload("res://main/dungeon/player/player_ok.png")
	]
	%PlayerIcon.texture = icons[3]
	
	for i in range(3):
		if stats[i] > 2 * lowest_stat:
			%PlayerIcon.texture = icons[i]
	%PlayerIcon.visible = true

func trans_out() -> void:
	%StatLabels.visible_ratio = 0
	%StatValues.visible_ratio = 0
	%StatLabels.text = ""
	%StatValues.text = ""
	%PlayerIcon.visible = false
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size:y", 0, 0.125)
	await tween.finished
	visible = false

func open() -> void:
	%StatLabels.visible_ratio = 0
	%StatLabels.text = "Life:\nStrength:\nDexterity:\nWisdom:"
	
	%StatValues.visible_ratio = 0
	%StatValues.text = "%d/%d\n%d\n%d\n%d\n" % [
		Status.player_stats.life, Status.player_stats.max_life,
		Status.player_stats.strength,
		Status.player_stats.dexterity,
		Status.player_stats.wisdom,
	]
	
	#var tween: Tween = get_tree().create_tween().set_parallel(true)
	#tween.tween_property(%StatLabels, "visible_ratio", 1.0, 0.1)
	#tween.tween_property(%StatValues, "visible_ratio", 1.0, 0.1)
	#await tween.finished
	%StatLabels.visible_ratio = 1
	%StatValues.visible_ratio = 1
	
	await advanced
	AudioManager.play_sound("accept", 2)
