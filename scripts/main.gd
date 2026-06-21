# Adapted from Godot's First 2D Game tutorial
extends Node

@export var enemy_scene: PackedScene
var score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func game_over():
	$ScoreTimer.stop()
	$EnemyTimer.stop()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()

func _on_score_timer_timeout():
	score += 1

func _on_start_timer_timeout():
	$EnemyTimer.start()
	$ScoreTimer.start()
	
func _on_enemy_timer_timeout():
	# Create new instance of the enemy
	var enemy = enemy_scene.instantiate()
	
	# Choose a random location along the Path2D 
	var enemy_spawn_location = $EnemyPath/EnemySpawnLocation
	enemy_spawn_location.progress_ratio = randf()
	
	# Set the enemy to a random location 
	enemy.position = enemy_spawn_location.position
	
	# Set the enemy direction to be perpendicular to the path
	var direction = enemy_spawn_location.rotation + PI / 2
	
	direction += randf_range(-PI/4, PI/4)
	enemy.rotation = direction
	
	# Set the velocity 
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	enemy.linear_velocity = velocity.rotated(direction)
	
	# Spawn the enemy by adding it as a child of the Main scene
	add_child(enemy)
