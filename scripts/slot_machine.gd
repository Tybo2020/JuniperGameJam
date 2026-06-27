extends CanvasLayer
@onready var slotMachineSprite = $slot_machine_sprite
@onready var leverHighlight = $lever_highlight
@onready var cardContainer = $card_container
@onready var descriptionLabel = $description_label
@onready var spinSfx = $SpinSfx
@onready var selectSfx = $SelectSfx

var hasBeenPulled: bool = false
signal spin_finished 

func _ready() -> void:
	leverHighlight.modulate = Color(1.0, 1.0, 1.0, 0.0)
	cardContainer.upgrade_chosen.connect(_on_upgrade_chosen)
	cardContainer.show_description.connect(_on_card_hovered)
	cardContainer.hide_description.connect(_on_card_unhovered)
	
	# Wait one frame before playing to ensure web renderer is ready
	await get_tree().process_frame
	slotMachineSprite.play("loop")

func _on_clicked():
	if hasBeenPulled:
		return
	
	spinSfx.play()
	get_tree().create_timer(5).timeout.connect(spinSfx.stop, CONNECT_ONE_SHOT)
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
	selectSfx.play(0.5)
	get_tree().create_timer(3).timeout.connect(selectSfx.stop, CONNECT_ONE_SHOT)
	
	cardContainer.clear_cards()
	hide()
	hasBeenPulled = false
	# Disable input on all cards
	for card in cardContainer.get_children():
		card.set_process_input(false)

func _on_card_hovered(description: String) -> void:
	descriptionLabel.text = description
	descriptionLabel.show()

func _on_card_unhovered() -> void:
	descriptionLabel.hide()
