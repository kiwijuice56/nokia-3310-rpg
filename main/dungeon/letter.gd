extends Sprite2D

func _ready() -> void:
	$Timer.timeout.connect(switch)
	

func switch() -> void:
	frame = randi() % 7
