extends CharacterBody2D

###### Launch configuration #######
@export var maxChargeTime: float = 1.0
@export var minLaunchStrength: float = 50.0
@export var maxLaunchStrength: float = 500.0 
@export var launchDecay: float = 2.0

var isCharging: bool = false
var isLaunched: bool = false
var currentChargeTime: float = 0.0
var launchVelocity: Vector2 = Vector2.ZERO

###### Bounce Configuration #######
@onready var bounceDetector: Area2D = $BounceDetector
@export var maxBounces: int = 3
@export var bounceWindowDuration: float = 0.2 # 12 frames at 60fps
@export var bounceCooldown: float = 0.4

var bounces: int = 0
var isBouncing: bool = false
var canBounce: bool = true
var comboCounter: int = 0

const SPEED = 300.0
func _ready() -> void:
	# Connect signal so it triggers if an object enters while pressing bounce key
	bounceDetector.body_entered.connect(_on_bounce_detector_body_entered)
	

func _on_bounce_detector_body_entered(body: Node2D) -> void:
	if isBouncing:
		executeSuccessfulBounce(body, null)

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
	if collisionInfo and isBouncing:
		executeSuccessfulBounce(collisionInfo.get_collider(), collisionInfo)
	
	if isLaunched:
		velocity = velocity.move_toward(Vector2.ZERO, velocity.length() * (delta / launchDecay))
		#print("Velocity: ", velocity)
		
func _input(event):
	if event.is_action_pressed("charge"):
		print("Charge key pressed")
		isCharging = true
		currentChargeTime = 0.0
	
	if event.is_action_released("charge") and isCharging:
		print("Charge released, launching")
		executeLaunch()
	
	if event.is_action_pressed("bounce") and canBounce:
		triggerBounceWindow()
		
func handleBounce(collision: KinematicCollision2D) -> void:
	bounces += 1
	if bounces > maxBounces:
		bounces = 0
		return
	
	var reflect = collision.get_remainder().bounce(collision.get_normal())
	## Calculate the bounce direction
	velocity = velocity.bounce(collision.get_normal())
	move_and_collide(reflect)
	
func executeLaunch() -> void:
	isCharging = false 
	isLaunched = true
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

func triggerBounceWindow() -> void:
	isBouncing = true
	canBounce = false
	print("Bounce window OPENED")
	
	# Create a timer for the duration of the window
	await get_tree().create_timer(bounceWindowDuration).timeout
	isBouncing = false
	print("Bounce window Closed")
	
	# Create a timer for the recovery cooldown penalty 
	# Can decide later if we want to keep a penalty or find another way 
	# to reward the player for timing the bounce successfully
	await get_tree().create_timer(bounceCooldown).timeout
	canBounce = true

func executeSuccessfulBounce(obstacle: Node2D, collision: KinematicCollision2D = null) -> void:
	# Close the bounce window on success
	isBouncing = false
	print("Successfully timed bounce on: ", obstacle.name)
	
	# If executed on an enemy, destory it here 
	
	# Execute the bounce 
	if collision:
		handleBounce(collision)
	# Update combo counter 
	comboCounter += 1
	
	# Update game feel 
	
