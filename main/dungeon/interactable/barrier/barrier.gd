class_name Barrier
extends Interactable

@export var convo: Array[Line]
@export var fail_convo: Array[Line]
@export var success_convo: Array[Line]
@export var min_stat: int
@export_enum("Strength", "Wisdom", "Dexterity") var stat: String = "Strength"
@export var custom_id: String

func _ready() -> void:
	custom_id = name
	if custom_id in Status.player_stats.flags:
		queue_free()
	
	fail_convo = fail_convo.duplicate(true)
	success_convo = success_convo.duplicate(true)
	convo = convo.duplicate(true)
	for i in range(len(convo)):
		convo[i] = convo[i].duplicate(true)
	for i in range(len(fail_convo)):
		fail_convo[i] = fail_convo[i].duplicate(true)
	for i in range(len(success_convo)):
		success_convo[i] = success_convo[i].duplicate(true)

func interact(player: Player) -> void:
	player.can_move = false
	await Ref.textbox.trans_in()
	await Ref.textbox.convo(convo)
	if Status.player_stats.get(stat.to_lower()) < min_stat:
		fail_convo[0].text = fail_convo[0].text % [min_stat, stat] 
		await Ref.textbox.convo(fail_convo)
	else:
		Status.player_stats.flags[custom_id] = true
		success_convo[0].text = success_convo[0].text % stat
		await Ref.textbox.convo(success_convo)
	await Ref.textbox.trans_out()
	if custom_id in Status.player_stats.flags:
		queue_free()
	player.can_move = true
