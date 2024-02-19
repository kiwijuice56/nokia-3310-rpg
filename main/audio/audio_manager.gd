extends Node

var loaded: bool = false
var sounds: Dictionary = {}
var instances: Array[AudioInstance]

signal finished_loading

func _ready() -> void:
	for path in ["res://main/audio/sfx/", "res://main/audio/music/"]:
		var dir: DirAccess = DirAccess.open(path)
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".wav"):
				sounds[file_name.replace(".wav", "")] = load(dir.get_current_dir() + "/" + file_name)
			file_name = dir.get_next()
	loaded = true

func play_sound(sound: String, priority: int, volume: float = 0):
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.volume_db = volume
	player.stream = sounds[sound]
	add_child(player)
	
	var instance: AudioInstance = AudioInstance.new()
	
	instance.player = player
	instance.priority = priority
	instance.sound = sound
	player.finished.connect(_on_instance_finished.bind(instance))
	player.play()
	
	instances.append(instance)
	validate_sound() 

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
			instance.player.bus = StringName("Silent")
	priority_sound.player.bus =  StringName("Master")
