extends Node

var player_stats: PlayerStats 

func _ready() -> void:
	load_file()
	if player_stats == null:
		player_stats = PlayerStats.new()
		player_stats.max_life = 10
		player_stats.life = 10
		player_stats.strength = 3
		player_stats.dexterity = 3
		player_stats.wisdom = 3
		player_stats.items = {"Gold": 10, "Soma": 3, "Bomb": 3}
		player_stats.shop_prices = [6, 6, 6, 6]

func load_file() -> void:
	if ResourceLoader.exists("user://data.tres"):
		player_stats = ResourceLoader.load("user://data.tres")

func save_file() -> void:
	ResourceSaver.save(player_stats, "user://data.tres")
