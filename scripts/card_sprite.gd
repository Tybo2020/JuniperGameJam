extends Panel

@onready var modifierSprite = $modifier_sprite
@onready var nameLabel = $name_label
@onready var descriptionLabel = $description_label

var upgrade_data: UpgradeData = null

signal upgrade_selected(upgrade_data)
signal card_hovered(description: String)
signal card_unhovered

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	set_process_input(true)
	descriptionLabel.hide()

func _on_mouse_entered() -> void:
	modulate = Color(1.2, 1.2, 1.2)
	card_hovered.emit(upgrade_data.description if upgrade_data else "")

func _on_mouse_exited() -> void:
	modulate = Color.WHITE
	card_unhovered.emit()
	
func setup(data: UpgradeData) -> void:
	upgrade_data = data
	if data.icon != null:
		modifierSprite.texture = data.icon
	nameLabel.text = data.name
	descriptionLabel.text = data.description

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		if get_global_rect().has_point(mouse_pos):
			_on_clicked()

func _on_clicked() -> void:
	print("clicked!")
	if upgrade_data == null:
		return
	upgrade_selected.emit(upgrade_data)
