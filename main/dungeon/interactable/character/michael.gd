class_name Michael
extends Character

@export var no_key_convo: Array[Line]
@export var encounter: Enemy
@export var custom_id: String

func _ready() -> void:
	custom_id = name
	if custom_id in Status.player_stats.flags:
		queue_free()

func interact(player: Player) -> void:
	player.can_move = false
	await Ref.textbox.trans_in()
	
	if "Key" in Status.player_stats.items:
		await Ref.textbox.convo(convo)
	else:
		await Ref.textbox.convo(no_key_convo)
		await Ref.textbox.trans_out()
		player.can_move = true
		return
	await Ref.textbox.trans_out()
	
	if await Ref.fight_manager.fight(encounter):
		Status.player_stats.flags[custom_id] = true
		queue_free()
	
	player.can_move = true
