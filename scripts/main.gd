# Adapted from Godot's First 2D Game tutorial
extends Node
@onready var heartsContainer = $CanvasLayer/health_container
@onready var comboSprite = $combo_sprite
@onready var slotMachineSprite = $SlotMachine/slot_machine_sprite
@onready var statsPanel = $CanvasLayer2/stats_panel

@export var warning_scene: PackedScene 
@export var enemy_scene: PackedScene
@export var maxEnemyCount: int = 5
var currentEnemyCount: int
var score
var currentWave: int = 0
var killCount: int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		print("Pause pressed, visible: ", statsPanel.visible)
		statsPanel.toggleVisibility($Player, currentWave)
	elif event.is_action_pressed("ui_cancel"):
		print("Escape pressed, visible: ", statsPanel.visible)
		if statsPanel.visible:
			statsPanel.hide()
			get_tree().paused = false
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()
	$Player.hit.connect(heartsContainer.updateHearts)
	#$Player.healed.connect(heartsContainer.updateHearts)
	$Player.max_health_changed.connect(func(newMax):
		await heartsContainer.setMaxHearts(newMax)
		heartsContainer.updateHearts($Player.currentHealthCount))
	$Player.deflect.connect(comboSprite.update)
	$SlotMachine.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func game_over():
	$ScoreTimer.stop()
	$EnemyTimer.stop()

func new_game():
	score = 0
	currentWave = 0
	heartsContainer.setMaxHearts($Player.maxHealthCount)
	$Player.start($StartPosition.position)
	$StartTimer.start()

func _on_score_timer_timeout():
	score += 1

func _on_start_timer_timeout():
	$ScoreTimer.start()
	start_next_wave()
	
func _on_enemy_timer_timeout():
	if currentEnemyCount >= maxEnemyCount:
		$EnemyTimer.stop()
		return
	
	currentEnemyCount += 1
	var enemy = enemy_scene.instantiate()
	var warning = warning_scene.instantiate()
	add_child(warning)
	
	# Choose a random location along the Path2D 
	var enemy_spawn_location = $EnemyPath/EnemySpawnLocation
	enemy_spawn_location.progress_ratio = randf()
	
	# Capture position before awaiting to prevent race condition
	var spawn_position = enemy_spawn_location.position
	
	# Set warning location to be at the same point as the enemy spawn
	warning.setup(spawn_position, 2.0)
	
	# Wait for warning timer
	await get_tree().create_timer(2.0, true).timeout
	
	# Set the enemy to spawn position
	enemy.position = spawn_position
	
	# Scale enemy speed with wave number
	var waveSpeedMultiplier = 1.0 + (currentWave - 1) * 0.1
	var speed = randf_range(150.0, 250.0) * waveSpeedMultiplier
	var direction = randf_range(0, TAU)
	enemy.linear_velocity = Vector2(speed, 0.0).rotated(direction)
	
	# Connect died signal to keep track of when to end the wave
	enemy.died.connect(_on_enemy_died)
	# Spawn the enemy by adding it as a child of the Main scene
	add_child(enemy)
	
	# Restart timer to spawn next enemy
	if currentEnemyCount < maxEnemyCount:
		$EnemyTimer.start()
		
func _on_enemy_died() -> void:
	killCount += 1
	# Check if all enemies that were spawned this wave have died
	if killCount >= maxEnemyCount:
		end_wave()

func start_next_wave() -> void:
	heartsContainer.updateHearts($Player.currentHealthCount)
	currentWave += 1
	currentEnemyCount = 0
	killCount = 0
	
	# Scale difficulty each wave
	if currentWave > 1:
		# More enemies each wave
		maxEnemyCount += 3
		# Increase kill threshold so players need higher combo at later waves
		$Player.killVelocityThreshold += 50.0
	
	$EnemyTimer.start()

func end_wave() -> void:
	$ScoreTimer.stop()
	$EnemyTimer.stop()
	await get_tree().create_timer(2.0).timeout
	$SlotMachine.show()
	if not $SlotMachine.spin_finished.is_connected(_on_spin_finished):
		$SlotMachine.spin_finished.connect(_on_spin_finished, CONNECT_ONE_SHOT)

func _on_spin_finished() -> void:
	var card_container = $SlotMachine/card_container
	if not card_container.upgrade_chosen.is_connected(_on_upgrade_chosen):
		card_container.upgrade_chosen.connect(_on_upgrade_chosen, CONNECT_ONE_SHOT)

func _on_upgrade_chosen() -> void:
	start_next_wave()
