class_name Room
extends Node2D

@export var music: String

func _ready() -> void:
	$CollisionTileMap.collision_visibility_mode = TileMap.VISIBILITY_MODE_FORCE_HIDE
	if len(music) > 0:
		AudioManager.play_sound(music, 0)
