class_name ItemBox
extends PanelContainer

const LABEL_SIZE: int = 29

signal advanced

var choice_idx: int = 0
var sound: AudioStream 

func _ready() -> void:
	%ItemLabels1.text = ""
	%ItemLabels2.text = ""
	%ItemCounts1.text = ""
	%ItemCounts2.text = ""
	size.y = 0
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("item", false):
		advanced.emit()
	if event.is_action_pressed("back", false):
		advanced.emit()

func trans_in() -> void:
	%ItemLabels1.text = ""
	%ItemLabels2.text = ""
	%ItemCounts1.text = ""
	%ItemCounts2.text = ""
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size:y", LABEL_SIZE, 0.125)
	await tween.finished

func trans_out() -> void:
	%ItemLabels1.visible_ratio = 0
	%ItemLabels2.visible_ratio = 0
	%ItemCounts1.visible_ratio = 0
	%ItemCounts2.visible_ratio = 0
	%ItemLabels1.text = ""
	%ItemLabels2.text = ""
	%ItemCounts1.text = ""
	%ItemCounts2.text = ""
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "size:y", 0, 0.125)
	await tween.finished
	visible = false

func open(items: Array[String], counts: Array[String]) -> void:
	if len(items) >= 4:
		%ItemLabels1.text = "\n".join(items.slice(0, 4))
		%ItemLabels2.text = "\n".join(items.slice(4))
		%ItemCounts1.text = "\n".join(counts.slice(0, 4))
		%ItemCounts2.text = "\n".join(counts.slice(4))
	else:
		%ItemLabels1.text = "\n".join(items)
		%ItemCounts1.text = "\n".join(counts)
	
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(%ItemLabels1, "visible_ratio", 1.0, 0.1)
	tween.tween_property(%ItemLabels2, "visible_ratio", 1.0, 0.1)
	tween.tween_property(%ItemCounts1, "visible_ratio", 1.0, 0.1)
	tween.tween_property(%ItemCounts2, "visible_ratio", 1.0, 0.1)
	await tween.finished
	
	await advanced
	AudioManager.play_sound("accept", 2)
