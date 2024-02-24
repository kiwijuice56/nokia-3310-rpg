class_name Dungeon
extends Node2D

@export var screen: Vector2
@export var music: Array[String] = []
@export var encounter_difficulty: Array[int] 

func _ready() -> void:
	var ahhh = {126: 1, 114: 1, 115: 1, 116: 1, 117: 2,
105: 2, 93: 2, 94: 2, 106: 2, 118: 2, 119: 2, 131: 2,
143: 2, 142: 2, 130: 1, 129: 0, 141: 0, 140: 1, 139: 1,
81: 2, 82: 2, 70: 3, 58: 3, 57: 3, 56: 3, 68: 3, 67: 3,
55: 3, 54: 3, 53: 3, 65 : 4, 66: 4, 78: 4, 90: 4,
89: 4, 88: 4, 76: 4, 77: 4, 64: 4, 63: 4, 62: 0, 50: 5,
51: 5, 52: 5, 40: 5, 28: 5, 29: 5, 30: 5,
31: 6, 43: 6, 44: 6, 45: 6, 46: 6, 34: 6, 35: 6,
47: 7, 59: 7, 71: 7, 17: 5, 5: 5, 18: 5, 6: 5,
7: 5, 8: 6, 9: 6, 21: 6, 33: 6, 32: 6,
61: 5, 73: 5, 72: 7, 84: 6, 85: 6, 86: 5,
87: 5, 75: 5, 74: 5, 99: 5, 98: 5, 97: 5, 96: 5,
137: 3, 125: 3, 113: 3, 112: 3, 124: 3, 136: 3,
135: 4, 134: 4, 122: 4, 110: 4, 109: 4, 108: 4, 120: 4, 121: 5,
133: 5, 132: 5, 60: 7, 48: 7, 36: 7, 37: 3, 25: 3, 26: 3,
14: 3, 13: 3, 12: 8, 0: 8, 1: 8, 2: 8, 3: 8, 4: 8}
	encounter_difficulty = []
	encounter_difficulty.resize(144)
	for key in ahhh:
		encounter_difficulty[key] = ahhh[key]
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
