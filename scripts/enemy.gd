extends RigidBody2D

const SPEED = 50
var player: Node2D = null
var currentAnimation: String = ""

@export var maxHealthCount: int = 2
var currentHealthCount: int = 0

var is_dying: bool = false
var is_hit: bool = false

signal died

func _ready() -> void:
	lock_rotation = true
	currentHealthCount = maxHealthCount
	add_to_group("enemies")
	
	# Store reference to player
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("Failed to grab player")

func _physics_process(_delta: float) -> void:
	if player:
		# Calculate direction towards player
		var direction = global_position.direction_to(player.global_position)
		linear_velocity = direction * SPEED
		
		# Play animations based on movement direction
		if abs(linear_velocity.x) > abs(linear_velocity.y):
			playAnimation("walk_side", linear_velocity.x < 0)
		else:
			if linear_velocity.y < 0:
				playAnimation("walk_up")
			else:
				playAnimation("walk_down")

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func die() -> void:
	if is_dying:
		return
	is_dying = true
	
	playAnimation("death")
	
	# Stop chasing the player
	set_physics_process(false)
	# Stop further collisions
	$CollisionShape2D.set_deferred("disabled", true)
	
	await get_tree().create_timer(0.5).timeout
	died.emit()
	queue_free()

func hit() -> void:
	if is_hit or is_dying:
		return
	is_hit = true
	
	currentHealthCount -= 1
	print("Enemy Health: ", currentHealthCount)
	
	# Die if health runs out
	if currentHealthCount <= 0:
		die()
		return
	
	# Brief invulnerability window after hit
	await get_tree().create_timer(0.3).timeout
	is_hit = false

func playAnimation(anim: String, flipH: bool = false) -> void:
	if currentAnimation != anim or $AnimatedSprite2D.flip_h != flipH:
		currentAnimation = anim
		$AnimatedSprite2D.flip_h = flipH
		$AnimatedSprite2D.play(anim)
