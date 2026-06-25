extends HBoxContainer

@onready var CardGuiClass = preload("res://scenes/UI/card_sprite.tscn")
@onready var UpgradeDataClass = preload("res://scripts/upgrade_data.gd")

var allPerks: Array = []
var last_perk: UpgradeData
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# create upgrades 
	allPerks = [
		create_upgrade("Extra Health", "Increase max heart count by 1", 1, "sprite path" ),
		create_upgrade("Combo Limit", "Increase max combo limit by 1 (Each combo increases 
						spin velocity 20%)", 1, "sprite path"),
		create_upgrade("Longer Deflect Window", "Increase perfect bounce timing window", 0.1, "sprite path")
						
	]

func _on_upgrade_selected(upgrade_data) -> void:
	# apply upgrade to player
	# hide upgrade UI
	pass

func displayUpgrades() -> void:
	var shuffled = allPerks.duplicate()
	shuffled.shuffle()
	
	for i in range(min(3, shuffled.size())):
		var card = CardGuiClass.instantiate()
		card.setup(shuffled[i])
		card.upgrade_selected.connect(_on_upgrade_selected)
		add_child(card)

func rerollUpgrade(index: int) -> void:
	var card = get_child(index)
	# Exclude the card's current perk
	var new_perk = getRandomPerk(card.upgrade_data) 
	card.setup(new_perk)
	

# Choose modifier and attach to card_sprite
func getRandomPerk(excludedPerk: UpgradeData = null) -> UpgradeData:
	var random_perk = allPerks[randi() % allPerks.size()]
	while random_perk == excludedPerk and allPerks.size() > 1:
		# Last perk was already chosen, try again until we find a unique one
		random_perk = allPerks[randi() % allPerks.size()]
	
	return random_perk

func create_upgrade(perkName: String, description: String, value: float, spritePath: String = "") -> UpgradeData:
	var data = UpgradeDataClass.new()
	data.name = perkName
	data.description = description
	data.value = value
	data.spritePath = spritePath
	return data
