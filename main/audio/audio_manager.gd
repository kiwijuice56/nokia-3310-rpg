extends Node

var loaded: bool = false
var sounds: Dictionary = {}
var instances: Array[AudioInstance]

signal finished_loading

func _ready() -> void:
	sounds["accept"] = preload("res://main/audio/sfx/accept.wav")
	sounds["bump"] = preload("res://main/audio/sfx/bump.wav")
	sounds["heal"] = preload("res://main/audio/sfx/heal.wav")
	sounds["mundane_mystery"] = preload("res://main/audio/music/mundane_mystery.wav")
	loaded = true

func play_sound(sound: String, priority: int, volume: float = 0):
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.volume_db = volume
	player.stream = sounds[sound]
	add_child(player)
	
	var instance: AudioInstance = AudioInstance.new()
	
	instance.player = player
	instance.volume = volume
	instance.priority = priority
	instance.sound = sound
	player.finished.connect(_on_instance_finished.bind(instance))
	player.play()
	
	instances.append(instance)
	validate_sound() 

func stop_sound(sound: String) -> void:
	for instance in instances:
		if instance.sound == sound:
			_on_instance_finished(instance)
			validate_sound()
			return

func is_playing(sound: String):
	for instance in instances:
		if instance.sound == sound:
			return true
	return false

func _on_instance_finished(instance: AudioInstance):
	instances.remove_at(instances.find(instance))
	instance.player.queue_free()
	validate_sound() 

func validate_sound() -> void:
	if len(instances) == 0:
		return
	var priority_sound: AudioInstance = instances[0]
	for instance in instances:
		if instance.priority > priority_sound.priority:
			priority_sound = instance
	for instance in instances:
		if not instance == priority_sound:
			instance.player.volume_db = -80
	priority_sound.player.volume_db = priority_sound.volume
