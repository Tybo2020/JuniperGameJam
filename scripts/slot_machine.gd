extends CanvasLayer
@onready var slotMachineSprite = $slot_machine_sprite
@onready var leverHighlight = $lever_highlight
@onready var cardContainer = $card_container
@onready var descriptionLabel = $description_label

var hasBeenPulled: bool = false
signal spin_finished 

func _ready() -> void:
	leverHighlight.modulate = Color(1.0, 1.0, 1.0, 0.0)
	cardContainer.upgrade_chosen.connect(_on_upgrade_chosen)
	cardContainer.show_description.connect(_on_card_hovered)
	cardContainer.hide_description.connect(_on_card_unhovered)
	slotMachineSprite.play("loop")

func _on_clicked():
	if hasBeenPulled:
		return
	hasBeenPulled = true
	leverHighlight.modulate = Color(1.0, 1.0, 1.0, 0.0)
	slotMachineSprite.play("spin")
	
	# Wait for spin to finish
	await slotMachineSprite.animation_finished
	# Return to loop animation
	slotMachineSprite.play("loop")
	cardContainer.displayNewUpgrades()
	spin_finished.emit()

func _on_lever_hitbox_mouse_entered() -> void:
	# Highlight the lever visually
	leverHighlight.modulate = Color(1.2, 1.2, 1.2, 1.0)

func _on_lever_hitbox_mouse_exited() -> void:
	# Return to normal
	leverHighlight.modulate = Color(1.0, 1.0, 1.0, 0.0)

func _on_lever_hitbox_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_on_clicked()

func _on_upgrade_chosen() -> void:
	hide()
	hasBeenPulled = false

func _on_card_hovered(description: String) -> void:
	descriptionLabel.text = description
	descriptionLabel.show()

func _on_card_unhovered() -> void:
	descriptionLabel.hide()
