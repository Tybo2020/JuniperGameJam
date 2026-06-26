extends Control

@onready var statNodes = [$Sprite2D, $Sprite2D2, $Sprite2D3, $Sprite2D4, $Sprite2D5]
@onready var stageLabel = $StageLabel

func _ready() -> void:
	hide()

func updateStats(player, wave: int) -> void:
	stageLabel.text = "Stage: " + str(wave)
	
	var stats = [
		["Max Health", str(player.maxHealthCount)],
		["Combo Limit", str(player.maxComboCount)],
		["Combo Multiplier", str(player.comboVelocityMultiplier)],
		["Bounce Window", str(player.bounceWindowDuration)],
		["Charge Time", str(player.maxChargeTime)]
	]
	
	for i in range(statNodes.size()):
		statNodes[i].get_node("StatName").text = stats[i][0]
		statNodes[i].get_node("Value").text = stats[i][1]

func toggleVisibility(player, wave: int) -> void:
	if visible:
		hide()
		get_tree().paused = false
	else:
		updateStats(player, wave)
		show()
		get_tree().paused = true
