extends Panel

@onready var modifierSprite = $card_art/modifier_sprite

var upgrade_data = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

signal upgrade_selected(upgrade_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(data):
	upgrade_data = data

func _on_mouse_entered():
	# highlight this card visually
	modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited():
	# return to normal
	modulate = Color.WHITE

func _on_clicked():
	pass
	# tell the manager this card was chosen
	upgrade_selected.emit(upgrade_data)
