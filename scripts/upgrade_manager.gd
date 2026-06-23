extends HBoxContainer

@onready var CardGuiClass = preload("res://scenes/UI/card_sprite.tscn")
@onready var UpgradeDataClass = preload("res://scripts/upgrade_data.gd")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 
	# create upgrades 

func _on_upgrade_selected(upgrade_data) -> void:
	# apply upgrade to player
	# hide upgrade UI
	pass

func displayUpgrades() -> void:
	var options = getRandomUpgrades(3)
	for upgrade in options:
		var card = CardGuiClass.instantiate()
		card.setup(upgrade)
		card.upgrade_selected.connect(_on_upgrade_selected)
		add_child(card)

func rerollUpgrade(index: int) -> void:
	pass

# Choose modifier and attach to card_sprite
func getRandomUpgrades(amount: int) -> Array:
	return []
	#

func create_upgrade(name: String, description: String, value: float, spritePath: String = "") -> UpgradeData:
	var data = UpgradeDataClass.new()
	data.name = name
	data.description = description
	data.value = value
	data.spritePath = spritePath
	return data
