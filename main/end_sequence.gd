extends PanelContainer

signal restart


func end() -> void:
	visible = true
	$Label.visible_ratio = 0
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Label, "visible_ratio", 1.0, 16.0)
	await tween.finished
	var timer = get_tree().create_timer(5.0)
	await timer.timeout
	$Label.text = "The end."
	$Label.visible_ratio = 0
	tween = get_tree().create_tween()
	tween.tween_property($Label, "visible_ratio", 1.0, 1.0)
	await tween.finished
	await restart
