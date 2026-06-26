extends Panel
@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update(0)


func update(comboCount: int):
	sprite.frame = comboCount
