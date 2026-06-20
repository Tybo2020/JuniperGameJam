extends CharacterBody2D

const SPEED = 50
var player: Node2D = null
@export var parryWindow: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	print("ready function called")
	# Store reference to player
	player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		print("failed to grab player ")
		
	print("Player position: ", player.global_position)
	

func _physics_process(_delta: float) -> void:
	if player:
		if isParryable():
			print("parryable")
		# Calculate direction towards player
		var direction = global_position.direction_to(player.global_position)

		velocity = direction * SPEED
		move_and_slide()
		
func isParryable() -> bool:
	if player: 
		# Check if player is within bounce range 
		var distance = player.global_position.distance_to(global_position)
		if distance < 10:
			return true
	return false
