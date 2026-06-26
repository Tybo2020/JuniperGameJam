extends HBoxContainer

@onready var CardGuiClass = preload("res://scenes/UI/card_sprite.tscn")
@onready var UpgradeDataClass = preload("res://scripts/upgrade_data.gd")

var allPerks: Array = []
signal upgrade_chosen
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# create upgrades 
	allPerks = [
		create_upgrade("Extra Health", "Increase max heart count by 1", 1, "sprite path" ),
		create_upgrade("Restoration", "Recover 1 heart", 1, "path"),
		create_upgrade("Combo Limit", "Increase max combo limit by 1 (Each combo increases 
						spin velocity by 20%)", 1, "sprite path"),
		create_upgrade("Combo Upgrade", "Increase combo scaling by an additional 5%", 0.05, "path"),
		create_upgrade("Longer Deflect Window", "Increase perfect bounce timing window", 0.1, "sprite path"),
		create_upgrade("Haste", "Decrease charge time", 1, "path"),
		create_upgrade("Dash attack", "Unlocks the dash attack skill", 1, "path")
						
	]

func _on_upgrade_selected(upgrade_data: UpgradeData) -> void:
	applyUpgrade(upgrade_data)
	
	# Notify slot machine the choice is made
	upgrade_chosen.emit()

func applyUpgrade(upgrade_data: UpgradeData) -> void:
	# Apply the upgrade effect to the player
	pass

func displayNewUpgrades() -> void:
	# Clear any cards from previous wave first
	for card in get_children():
		card.queue_free()
	
	# Instantiate fresh cards, ensure no duplicates appear in the same roll
	var usedPerks: Array = []
	for i in range(3):
		var card = CardGuiClass.instantiate()
		card.upgrade_selected.connect(_on_upgrade_selected)
		add_child(card)
		var perk = getRandomPerk()
		while perk in usedPerks:
			perk = getRandomPerk()
		usedPerks.append(perk)
		card.setup(perk)
		
# Choose perk and attach to card_sprite
func getRandomPerk() -> UpgradeData:
	return allPerks[randi() % allPerks.size()]

# Will need to change icon to Texture 2D instead of string
func create_upgrade(perkName: String, description: String, value: float, spriteIcon: String = "") -> UpgradeData:
	var data = UpgradeDataClass.new()
	data.name = perkName
	data.description = description
	data.value = value
	data.icon = spriteIcon
	return data
