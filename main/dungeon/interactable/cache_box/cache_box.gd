class_name CacheBox
extends Interactable

@export var convo: Array[Line]
@export var item: String
@export var count: int
@export var custom_id: String

func _ready() -> void:
	custom_id = name
	if custom_id in Status.player_stats.flags:
		queue_free()
	convo = convo.duplicate(true)
	for i in range(len(convo)):
		convo[i] = convo[i].duplicate(true)

func interact(player: Player) -> void:
	if item == "Gold":
		count = round(count * (randf_range(0.5, 0.9) + (Status.player_stats.wisdom / 8.0)))
		if count <= 0:
			count = 1
	
	convo[1].text = "(Inside, you find %d %s.)" % [count, item] 
	player.can_move = false
	await Ref.textbox.trans_in()
	await Ref.textbox.convo(convo)
	await Ref.textbox.trans_out()
	if not item in Status.player_stats.items:
		Status.player_stats.items[item] = 0
	Status.player_stats.items[item] += count
	Status.player_stats.flags[custom_id] = true
	queue_free()
	player.can_move = true
