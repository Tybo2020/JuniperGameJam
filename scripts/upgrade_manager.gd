extends HBoxContainer

@onready var CardGuiClass = preload("res://scenes/UI/card_sprite.tscn")
@onready var UpgradeDataClass = preload("res://scripts/upgrade_data.gd")

const healthUpgradeTexture = preload("res://assets/heartperkupgrade.png")
const healthPotionTexture = preload("res://assets/perks/health_potion.png")
const reboundUpgradeTexture = preload("res://assets/perks/reboundupgrade.png")
const scytheUpgradeTexture = preload("res://assets/perks/Scythe_upgrade.png")
const hasteTexture = preload("res://assets/perks/stopwatch_haste.png")
const comboLimitTexture = preload("res://assets/combolimitperk.png")

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
		create_upgrade("Combo Limit", "Increase max combo limit by 1", 1, comboLimitTexture),
		create_upgrade("Scythe Upgrade", "Increase combo scaling by an additional 5%", 0.05, scytheUpgradeTexture),
		create_upgrade("Rebound Upgrade", "Increase perfect rebound timing window", 0.1, reboundUpgradeTexture),
		create_upgrade("Haste", "Decrease charge time by 20% ", 0.2, hasteTexture),
						
	]

func _on_upgrade_selected(upgrade_data: UpgradeData) -> void:
	# Disable all cards immediately to prevent double selection
	for card in get_children():
		card.set_process_input(false)
	applyUpgrade(upgrade_data)
	upgrade_chosen.emit()

func applyUpgrade(upgrade_data: UpgradeData) -> void:
	print("Success! Chosen Upgrade: ", upgrade_data.name)
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	match upgrade_data.name:
		"Health Upgrade":
			player.maxHealthCount += int(upgrade_data.value)
			# notify UI to update heart display
			player.max_health_changed.emit(player.maxHealthCount)
			
			print("Max Health: ", player.maxHealthCount)
		"Health Potion":
			player.currentHealthCount = min(player.currentHealthCount + 1, player.maxHealthCount)
			player.healed.emit(player.currentHealthCount)
			
			print("Current Health: ", player.currentHealthCount)
		"Combo Limit":
			player.maxComboCount += int(upgrade_data.value)
			print("Max Combo: ", player.maxComboCount)
		"Scythe Upgrade":
			# velocity multiplier in _deflect is 1.3, increase by 5%
			player.comboVelocityMultiplier += upgrade_data.value
			print("Combo Velocity Multiplier: ", player.comboVelocityMultiplier)
		"Rebound Upgrade":
			player.bounceWindowDuration += upgrade_data.value
			print("Bounce Window Duration: ", player.bounceWindowDuration)
		"Haste":
			player.maxChargeTime = max(player.maxChargeTime * 0.8, 0.5)
			print("Max Charge Time: ", player.maxChargeTime)
	

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
		card.set_process_input(true)
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

func clear_cards() -> void:
	for card in get_children():
		card.queue_free()
