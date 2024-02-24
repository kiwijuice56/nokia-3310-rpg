class_name Shop
extends Interactable

@export var convoa: Array[Line]
@export var convob: Array[Line]
@export var convoc: Array[Line]

var index: int = 0

func interact(player: Player) -> void:
	player.can_move = false
	await Ref.textbox.trans_in()
	await Ref.textbox.convo([convoa, convob, convoc][index])
	await Ref.shop_menu.shop()
	await Ref.textbox.trans_out()
	index = (index + 1) % 3
	player.can_move = true
