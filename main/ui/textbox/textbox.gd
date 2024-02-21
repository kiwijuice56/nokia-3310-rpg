class_name TextBox
extends PanelContainer

const LABEL_SIZE: int = 29

signal advanced

var choice_idx: int = 0
var visible_char: int = 0:
	set(val):
		visible_char = val
		%Label.set_visible_characters(val)
var sound: AudioStream 

func _ready() -> void:
	%Label.text = ""
	size.y = 0
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept", false):
		advanced.emit()

func trans_in() -> void:
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size:y", LABEL_SIZE, 0.125)
	await tween.finished

func trans_out() -> void:
	%Label.visible_characters = 0
	%Label.text = ""
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size:y", 0, 0.125)
	await tween.finished
	visible = false

func convo(lines: Array[Line]) -> void:
	for i in range(len(lines)):
		$MiniDelay.start()
		await $MiniDelay.timeout
		
		var line: Line = lines[i]
		
		if len(line.sound) > 0:
			AudioManager.play_sound(line.sound, 2)
		
		%Label.visible_characters = 0
		%Label.text = line.text
		
		visible_char = 0
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "visible_char", len(line.text), line.speed * len(line.text) * 0.4)
		await tween.finished
		
		await advanced
		AudioManager.play_sound("accept", 2)
