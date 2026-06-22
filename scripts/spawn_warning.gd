extends Node2D

@onready var timer = $Timer
@onready var panel = $ColorRect

func _ready() -> void:
	hide()
	
func setup(spawn_position: Vector2, duration: float):
	show()
	# Position the visual notification at the world spawn coordinates
	global_position = spawn_position
	
	timer.start(duration)
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	# Remove the notification when time is up
	queue_free() 
