extends Node2D
@onready var timer = $Timer
@onready var panel = $ColorRect

func _ready() -> void:
	hide()
	timer.timeout.connect(_on_timer_timeout)
	
func setup(spawn_position: Vector2, duration: float) -> void:
	show()
	position = get_edge_position(spawn_position)
	timer.start(duration)  # fallback in case enemy never spawns

func _on_timer_timeout():
	# Remove the notification when time is up
	queue_free() 

func get_edge_position(spawn_pos: Vector2) -> Vector2:
	var center = Vector2(327, 177)
	var screen_size = get_viewport_rect().size
	
	# Get direction from arena center to spawn point
	var direction = (spawn_pos - center).normalized()
	var t = INF
	
	# Find closest screen edge in that direction
	if direction.x != 0:
		t = min(t, -center.x / direction.x if direction.x < 0 else (screen_size.x - center.x) / direction.x)
	if direction.y != 0:
		t = min(t, -center.y / direction.y if direction.y < 0 else (screen_size.y - center.y) / direction.y)
	
	# Return the point on the screen edge
	return center + direction * t
