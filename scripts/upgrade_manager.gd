extends HBoxContainer

@onready var CardGuiClass = preload("res://scenes/UI/card_sprite.tscn")
@onready var UpgradeDataClass = preload("res://scripts/upgrade_data.gd")

const healthUpgradeTexture = preload("res://assets/perks/HEALTHUPGRADE.png")
const healthPotionTexture = preload("res://assets/perks/health_potion.png")
const reboundUpgradeTexture = preload("res://assets/perks/reboundupgrade.png")
const scytheUpgradeTexture = preload("res://assets/perks/Scythe_upgrade.png")
const hasteTexture = preload("res://assets/perks/stopwatch_haste.png")
const comboLimitTexture = preload("res://assets/perks/combolimit.png")

var allPerks: Array = []
signal upgrade_chosen
signal show_description(description: String)
signal hide_description

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# create upgrades 
	allPerks = [
		create_upgrade("Health Upgrade", "Increase max heart count by 1", 1, healthUpgradeTexture),
		create_upgrade("Health Potion", "Recover 1 heart", 1, healthPotionTexture),
		create_upgrade("Combo Limit Break", "Increase max combo limit by 1. Each combo increases spin velocity by 20%", 1, comboLimitTexture),
		create_upgrade("Scythe Upgrade", "Increase combo scaling by an additional 5%", 0.05, scytheUpgradeTexture),
		create_upgrade("Rebound Upgrade", "Increase perfect rebound timing window", 0.1, reboundUpgradeTexture),
		create_upgrade("Haste", "Decrease charge time", 1, hasteTexture),
						
	]

func _on_upgrade_selected(upgrade_data: UpgradeData) -> void:
	applyUpgrade(upgrade_data)
	
	# Notify slot machine the choice is made
	upgrade_chosen.emit()

func applyUpgrade(upgrade_data: UpgradeData) -> void:
	print("Success! Chosen Upgrade: ", upgrade_data.name)
	

func displayNewUpgrades() -> void:
	# Clear cards from previous wave
	for card in get_children():
		card.queue_free()
	
	# Instantiate new cards, ensure there are no duplicates 
	var usedPerks: Array = []
	for i in range(3):
		var card = CardGuiClass.instantiate()
		card.upgrade_selected.connect(_on_upgrade_selected)
		card.card_hovered.connect(_on_card_hovered)
		card.card_unhovered.connect(_on_card_unhovered)
		add_child(card)
		var perk = getRandomPerk()
		while perk in usedPerks:
			perk = getRandomPerk()
		usedPerks.append(perk)
		card.setup(perk)
		
# Choose perk and attach to card_sprite
func getRandomPerk() -> UpgradeData:
	return allPerks[randi() % allPerks.size()]

func create_upgrade(perkName: String, description: String, value: float, spriteIcon: Texture2D = null) -> UpgradeData:
	var data = UpgradeDataClass.new()
	data.name = perkName
	data.description = description
	data.value = value
	data.icon = spriteIcon
	return data

func _on_card_hovered(description: String) -> void:
	show_description.emit(description)

func _on_card_unhovered() -> void:
	hide_description.emit()
