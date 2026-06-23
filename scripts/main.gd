# Adapted from Godot's First 2D Game tutorial
extends Node
@onready var heartsContainer = $CanvasLayer/health_container
@export var warning_scene: PackedScene 
@export var enemy_scene: PackedScene
@export var maxEnemyCount: int = 5
var currentEnemyCount: int
var score
var currentWave: int = 1
var killCount: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()
	$Player.hit.connect(heartsContainer.updateHearts)

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
	
	# Set warning location to be at the same point as the enemy spawn
	warning.setup(enemy_spawn_location.position, 2.0)
	
	# Wait for warning timer, pause enemy timer
	await get_tree().create_timer(2.0).timeout
	
	# Set the enemy to a random location 
	enemy.position = enemy_spawn_location.position
	
	# Set the enemy direction to be perpendicular to the path
	var direction = enemy_spawn_location.rotation + PI / 2
	direction += randf_range(-PI/4, PI/4)
	enemy.rotation = direction
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	enemy.linear_velocity = velocity.rotated(direction)
	
	# Connect died signal to keep track of when to end the wave
	enemy.died.connect(_on_enemy_died)
	# Spawn the enemy by adding it as a child of the Main scene
	add_child(enemy)
	
	# Stop after spawning the last enemy
	if currentEnemyCount >= maxEnemyCount:
		$EnemyTimer.stop()


func _on_enemy_died() -> void:
	killCount += 1
	# Check if all enemies that were spawned this wave have died
	if killCount == maxEnemyCount:
		end_wave()

func start_next_wave() -> void:
	currentWave += 1
	currentEnemyCount = 0
	killCount = 0
	
	# Only scale enemy count after wave 1
	if currentWave > 1:
		maxEnemyCount += 10
	$EnemyTimer.start()

func end_wave():
	$ScoreTimer.stop()
	$EnemyTimer.stop()
	# display upgrade screen
	
	await get_tree().create_timer(10.0).timeout
	# once upgrade is chosen, restart the start timer to begin the next wave
	start_next_wave()
	
