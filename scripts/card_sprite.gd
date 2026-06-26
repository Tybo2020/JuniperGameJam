extends Panel

@onready var modifierSprite = $modifier_sprite
@onready var nameLabel = $name_label
@onready var descriptionLabel = $description_label

var upgrade_data: UpgradeData = null

signal upgrade_selected(upgrade_data)

func setup(data: UpgradeData) -> void:
	upgrade_data = data
	modifierSprite.texture = data.icon
	nameLabel.text = data.upgrade_name
	descriptionLabel.text = data.description

func _on_mouse_entered() -> void:
	modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited() -> void:
	modulate = Color.WHITE

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_on_clicked()

func _on_clicked() -> void:
	if upgrade_data == null:
		return
	upgrade_selected.emit(upgrade_data)
