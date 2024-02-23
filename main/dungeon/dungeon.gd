class_name Dungeon
extends Node2D

@export var screen: Vector2
@export var music: Array[String] = []
@export var encounter_difficulty: Array[int] = []

func _ready() -> void:
	$CollisionTileMap.collision_visibility_mode = TileMap.VISIBILITY_MODE_FORCE_HIDE
	update_screen(Vector2(6, 11))

func update_screen(new_screen: Vector2) -> void:
	var index: int = screen.x + 12 * screen.y
	var new_index: int = new_screen.x + 12 * new_screen.y
	if not music[index] == music[new_index]:
		AudioManager.stop_sound(music[index])
		if len(music[new_index]) > 0:
			AudioManager.play_sound(music[new_index], 0)
	screen = new_screen

func get_difficulty() -> int:
	var index: int = screen.x + 12 * screen.y
	return encounter_difficulty[index]
