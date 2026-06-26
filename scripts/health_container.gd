extends HBoxContainer

@onready var HeartGuiClass = preload("res://scenes/UI/heart_sprite.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setMaxHearts(hearts: int) -> void:
	for heart in get_children():
		heart.queue_free()
	
	await get_tree().process_frame  # wait for old hearts to be removed
	
	for i in range(hearts):
		var heart = HeartGuiClass.instantiate()
		add_child(heart)
		
func updateHearts(currentHealth: int):
	var hearts = get_children()
	
	for i in range(currentHealth):
		hearts[i].update(true)
	
	for i in range(currentHealth, hearts.size()):
		hearts[i].update(false)
