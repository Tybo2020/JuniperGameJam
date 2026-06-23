extends RigidBody2D
const SPEED = 50
var player: Node2D = null
var isDying = false
var maxHealthCount = 2
var currentHealthCount = 0
var is_dying: bool = false
var is_hit: bool = false 

signal died
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()
	
	currentHealthCount = maxHealthCount
	add_to_group("enemies")
	# Store reference to player
	player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		print("failed to grab player ")
		
	#print("Player position: ", player.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	if player:
		# Calculate direction towards player
		var direction = global_position.direction_to(player.global_position)
		linear_velocity = direction * SPEED

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func die() -> void:
	if is_dying:
		return
	is_dying = true
	
	set_physics_process(false)  # stop chasing the player
	$CollisionShape2D.set_deferred("disabled", true)  # stop further collisions/bounces
	
	await get_tree().create_timer(0.5).timeout  # adjust delay as you like
	died.emit()
	queue_free()

func hit() -> void: 
	if currentHealthCount < 1:
		die()
		return
	if is_hit:
		return 
	else: 
		is_hit = true
	
	currentHealthCount -= 1
	#flash red, add slight delay to prevent dying instantly
	await get_tree().create_timer(0.5).timeout
	
