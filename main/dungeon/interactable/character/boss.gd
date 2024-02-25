class_name Boss
extends Character

@export var encounter: Enemy
@export var custom_id: String

func _ready() -> void:
	custom_id = name
	if custom_id in Status.player_stats.flags:
		queue_free()

func interact(player: Player) -> void:
	player.can_move = false
	await Ref.textbox.trans_in()
	await Ref.textbox.convo(convo)
	await Ref.textbox.trans_out()
	
	if await Ref.fight_manager.fight(encounter):
		Status.player_stats.flags[custom_id] = true
		queue_free()
	
	player.can_move = true
