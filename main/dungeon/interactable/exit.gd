class_name Exit
extends Character

func interact(player: Player) -> void:
	player.can_move = false
	await get_tree().get_root().get_node("Main/Screen/UI/EndSequence").end()
