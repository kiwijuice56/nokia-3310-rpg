class_name ShopMenu
extends PanelContainer

signal accepted(type)

var index: int = 0

func _ready() -> void:
	visible = false
	set_process_input(false)

func _input(event: InputEvent) -> void:
	var old_index: int = index
	if Input.is_action_just_pressed("ui_up"):
		index -= 1
	if Input.is_action_just_pressed("ui_down"):
		index += 1
	if Input.is_action_just_pressed("ui_left"):
		index -= 1
	if Input.is_action_just_pressed("ui_right"):
		index += 1
	if index < 0:
		index += 4
	
	index = index % 4
	
	if old_index != index:
		%StatContainer.get_child(old_index).get("theme_override_styles/normal").bg_color = Color("#000000")
		%StatContainer.get_child(old_index).set("theme_override_colors/font_color", Color("#879188"))
		
		%StatContainer.get_child(index).get("theme_override_styles/normal").bg_color = Color("#879188")
		%StatContainer.get_child(index).set("theme_override_colors/font_color", Color("#000000"))
		AudioManager.play_sound("accept", 1)
	if Input.is_action_just_pressed("accept"):
		accepted.emit(1)
		AudioManager.play_sound("accept", 1)
	if Input.is_action_just_pressed("back"):
		accepted.emit(-1)
		AudioManager.play_sound("bump", 1)


func update_prices() -> void:
	for i in range(4):
		%PriceContainer.get_child(i).text = str(Status.player_stats.shop_prices[i])
	%GoldLabel.text = "Gold: " + str(Status.player_stats.items["Gold"])

func shop() -> void:
	update_prices()
	visible = true
	
	%StatContainer.get_child(index).get("theme_override_styles/normal").bg_color = Color("#879188")
	%StatContainer.get_child(index).set("theme_override_colors/font_color", Color("#000000"))
	
	while true:
		set_process_input(true)
		if await accepted == -1:
			set_process_input(false)
			break
		set_process_input(false)
		if Status.player_stats.items["Gold"] >= Status.player_stats.shop_prices[index]:
			Status.player_stats.items["Gold"] -= Status.player_stats.shop_prices[index]
			var stat: String = ["max_life", "strength", "dexterity", "wisdom"][index]
			Status.player_stats.set(stat, Status.player_stats.get(stat) + 1)
			Status.player_stats.shop_prices[index] += 2
			AudioManager.stop_sound("good1")
			AudioManager.play_sound("good1", 2)
			update_prices()
		else:
			AudioManager.stop_sound("bump")
			AudioManager.play_sound("bump", 1)
	
	visible = false
