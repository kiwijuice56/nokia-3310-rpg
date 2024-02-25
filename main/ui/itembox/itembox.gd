class_name ItemBox
extends PanelContainer

const LABEL_SIZE: int = 29

signal advanced(type)

var choice_idx: int = 0
var sound: AudioStream 

var index: int = 0

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
		index += 3
	
	index = index % 8
	
	if old_index != index:
		%ItemContainer.get_child(old_index).get("theme_override_styles/normal").bg_color = Color("#000000")
		%ItemContainer.get_child(old_index).set("theme_override_colors/font_color", Color("#879188"))
		
		%ItemContainer.get_child(index).get("theme_override_styles/normal").bg_color = Color("#879188")
		%ItemContainer.get_child(index).set("theme_override_colors/font_color", Color("#000000"))
		AudioManager.stop_sound("accept")
		AudioManager.play_sound("accept", 1)
	if event.is_action_pressed("accept", false):
		advanced.emit(1)
	if event.is_action_pressed("back", false):
		advanced.emit(-1)

func _ready() -> void:
	set_process_input(false)
	for child in %ItemContainer.get_children():
		child.visible = false
	size.y = 0
	visible = false

func update_items():
	var items: Array[String] = ["Gold", "Soma", "Bomb", "Key", "Hex", "Orb", "Boots", "Sol"]
	for i in range(8):
		if i >= len(items) or not items[i] in Status.player_stats.items:
			%ItemContainer.get_child(i).text = ""
		else:
			%ItemContainer.get_child(i).text = items[i] + " x" + str(Status.player_stats.items[items[i]])
		if i != index:
			%ItemContainer.get_child(i).get("theme_override_styles/normal").bg_color = Color("#000000")
			%ItemContainer.get_child(i).set("theme_override_colors/font_color", Color("#879188"))
		else:
			%ItemContainer.get_child(i).get("theme_override_styles/normal").bg_color = Color("#879188")
			%ItemContainer.get_child(i).set("theme_override_colors/font_color", Color("#000000"))

func trans_in() -> void:
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size:y", LABEL_SIZE, 0.125)
	await tween.finished
	for child in %ItemContainer.get_children():
		child.visible = true

func trans_out() -> void:
	for child in %ItemContainer.get_children():
		child.visible = false
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size:y", 0, 0.125)
	await tween.finished
	visible = false


func open() -> void:
	update_items()
	
	%ItemContainer.get_child(index).get("theme_override_styles/normal").bg_color = Color("#879188")
	%ItemContainer.get_child(index).set("theme_override_colors/font_color", Color("#000000"))
	
	while true:
		set_process_input(true)
		var decision: int = await advanced
		set_process_input(false)
		if decision == 1:
			if index == 1 and Status.player_stats.items["Soma"] > 0:
				Status.player_stats.items["Soma"] -= 1
				Status.player_stats.life = Status.player_stats.max_life
				update_items()
				AudioManager.play_sound("heal", 2)
			else:
				AudioManager.stop_sound("bump")
				AudioManager.play_sound("bump", 2)
			Status.player_stats.life = Status.player_stats.max_life
		else:
			AudioManager.stop_sound("bump")
			AudioManager.play_sound("bump", 1)
			break
