extends CharacterBody2D

@export var maxBounces: int = 3
@export var maxChargeTime: float = 2.0
@export var minLaunchStrength: float = 50.0
@export var maxLaunchStrength: float = 1200.0 
@export var launchDecay: float = 5.0

var isCharging: bool = false
var currentChargeTime: float = 0.0
var launchVelocity: Vector2 = Vector2.ZERO

const SPEED = 300.0
var bounces: int = 0
func _physics_process(delta: float) -> void:
	## Get the input direction and handle the movement/deceleration.
	#var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
#
	## Normalize vectors
	#var direction = input_dir.normalized() 
#
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.y = direction.y * SPEED 
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.y = move_toward(velocity.y, 0, SPEED)
	
	if isCharging: 
		currentChargeTime += delta 
		print("ChargeTime: ", currentChargeTime)
		currentChargeTime = clamp(currentChargeTime, 0.0, maxChargeTime)
	
	var collisionInfo = move_and_collide(velocity * delta)
	
	if collisionInfo:
		handleBounce(collisionInfo)
		
func _input(event):
	if event.is_action_pressed("charge"):
		print("Charge key pressed")
		isCharging = true
		currentChargeTime = 0.0
	
	if event.is_action_released("charge") and isCharging:
		print("Charge released, launching")
		executeLaunch()

func handleBounce(collision: KinematicCollision2D) -> void:
	bounces += 1
	if bounces > maxBounces:
		bounces = 0
		return
		
	# Get the normal vector from the collision
	var collisionNormal = collision.get_normal()
	
	# Calculate the bounce direction
	velocity = velocity.bounce(collisionNormal)
	rotation = velocity.angle()
	
func executeLaunch() -> void:
	isCharging = false 
	# Calculate chargeTime ratio
	var chargeRatio = (currentChargeTime / maxChargeTime)

	# Calculate launchForce 
	var launchForce = lerp(minLaunchStrength, maxLaunchStrength, chargeRatio)

	# Determine launch direction 
	var launchDirection = get_local_mouse_position().normalized()
	print("Mouse position: ", launchDirection)

	# Apply velocity
	velocity = launchDirection * launchForce 
	print("Launch velocity: ", velocity)
