class_name HealthMachine
extends Interactable

@export var convo: Array[Line]

func interact(player: Player) -> void:
	player.can_move = false
	Status.player_stats.life = Status.player_stats.max_life
	await Ref.textbox.trans_in()
	await Ref.textbox.convo(convo)
	await Ref.textbox.trans_out()
	player.can_move = true
