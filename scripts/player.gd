extends CharacterBody2D
@onready var aim_line: Line2D = $AimLine
@export var lowChargeColor: Color = Color.YELLOW
@export var highChargeColor: Color = Color.RED
@export var healthCount: int = 3

###### Launch configuration #######
@export var maxChargeTime: float = 1.0
@export var maxLaunchPullback: float = 350.0 # pixels away from inital POS
@export var minLaunchStrength: float = 50.0
@export var maxLaunchStrength: float = 1000.0 
@export var launchDecay: float = 5
@export var killVelocityThreshold: float = 800.0
var isKillingEnemy: bool = false

var isCharging: bool = false
var isLaunched: bool = false
var currentChargeTime: float = 0.0
var launchVelocity: Vector2 = Vector2.ZERO

var initialMousePos: Vector2 = Vector2.ZERO
var chargeRatio: float = 0.0
var launchDirection: Vector2 = Vector2.ZERO

###### Bounce Configuration #######
@onready var bounceDetector: Area2D = $BounceDetector
@export var maxBounces: int = 3
@export var bounceWindowDuration: float = 0.4 # 12 frames at 60fps
@export var bounceCooldown: float = 0.4

var bounces: int = 0
var isBouncing: bool = false
var canBounce: bool = true
var comboCounter: int = 0

const HALT_SPEED = 1000
const SPEED = 100.0

signal hit

func _hit():
	pass

func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	
func _ready() -> void:
	hide()
	# Connect signal so it triggers if an object enters while pressing bounce key
	bounceDetector.body_entered.connect(_on_bounce_detector_body_entered)
	aim_line.visible = false
	
func _on_bounce_detector_body_entered(body: Node2D) -> void:
	if isBouncing:
		executeSuccessfulBounce(body, null)

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if !isLaunched && !isCharging:
		# Normalize vectors
		var direction = input_dir.normalized() 
		if direction:
			velocity = direction * SPEED
		else:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)

		
	if isCharging and !isLaunched:
		velocity = Vector2.ZERO
		var currentMousePos = get_local_mouse_position()
		var distance = currentMousePos.distance_to(initialMousePos)
		launchDirection = currentMousePos.direction_to(initialMousePos)
		chargeRatio = clamp(distance / maxLaunchPullback, 0.0, 1.0)
		
		update_aim_line()
	
	var collisionInfo = move_and_collide(velocity * delta)
	if collisionInfo and isBouncing:
		executeSuccessfulBounce(collisionInfo.get_collider(), collisionInfo)
	elif collisionInfo:
		handleBounce(collisionInfo)
		
	if isLaunched:
		#if not isKillingEnemy:
			## Do not decay velocity until after enemy is dead
			#pass
		#else:
		# Natural decay every frame
		velocity = velocity.move_toward(Vector2.ZERO, velocity.length() * (delta / launchDecay))

		# Hold "halt" to brake faster
		if Input.is_action_pressed("halt"):
			velocity = velocity.move_toward(Vector2.ZERO, HALT_SPEED * delta)

		# Clear launched state once basically stopped
		if velocity.length_squared() < 5.0:
			velocity = Vector2.ZERO
			isLaunched = false
		


func _input(event):
	if event.is_action_pressed("charge") and !isLaunched:
		isCharging = true
		initialMousePos = get_local_mouse_position()
		#print("Charge key pressed")
		#isCharging = true
		#currentChargeTime = 0.0
	
	if event.is_action_released("charge") and isCharging and !isLaunched:
		isCharging = false
		print("Charge released, launching")
		executeLaunch()
	
	if event.is_action_pressed("bounce") and canBounce:
		triggerBounceWindow()
		
func handleBounce(collision: KinematicCollision2D) -> void:
	bounces += 1
	if bounces > maxBounces:
		bounces = 0
		return
	var obstacle = collision.get_collider()
	
	if obstacle.is_in_group("enemies"):
		if velocity.length() >= killVelocityThreshold:
			isKillingEnemy = true
			obstacle.die()
			obstacle.died.connect(func(): isKillingEnemy = false, CONNECT_ONE_SHOT)
			return
		else:
			velocity = Vector2.ZERO
			return
	
	var reflect = collision.get_remainder().bounce(collision.get_normal())
	## Calculate the bounce direction
	velocity = velocity.bounce(collision.get_normal())
	move_and_collide(reflect)
	
func executeLaunch() -> void:
	isCharging = false 
	isLaunched = true
	# Calculate chargeTime ratio
	#chargeRatio = (currentChargeTime / maxChargeTime)

	# Calculate launchForce 
	var launchForce = lerp(minLaunchStrength, maxLaunchStrength, chargeRatio)

	# Determine launch direction 
	#launchDirection = get_local_mouse_position().normalized()
	print("Mouse position: ", launchDirection)

	# Apply velocity
	velocity = launchDirection * launchForce 
	print("Launch velocity: ", velocity)
	aim_line.visible = false

func triggerBounceWindow() -> void:
	isBouncing = true
	canBounce = false
	#print("Bounce window OPENED")
	
	# Create a timer for the duration of the window
	await get_tree().create_timer(bounceWindowDuration).timeout
	isBouncing = false
	#print("Bounce window Closed")
	
	# Create a timer for the recovery cooldown penalty 
	# Can decide later if we want to keep a penalty or find another way 
	# to reward the player for timing the bounce successfully
	#await get_tree().create_timer(bounceCooldown).timeout
	canBounce = true

func executeSuccessfulBounce(obstacle: Node2D, collision: KinematicCollision2D = null) -> bool:
	# Close the bounce window on success
	isBouncing = false
	#print("Successfully timed bounce on: ", obstacle.name)
	
	# If executed on an enemy, destory it here 
	if obstacle.is_in_group("enemies"):
		if velocity.length() >= killVelocityThreshold:
			isKillingEnemy = true
			obstacle.die()
			obstacle.died.connect(func(): isKillingEnemy = false, CONNECT_ONE_SHOT)
		else:
			obstacle.die()
	
	# Execute the bounce 
	if collision:
		handleBounce(collision)
	# Update combo counter 
	comboCounter += 1
	
	# Update game feel 
	velocity *= 1.2
	
	return true
# Temporary function to show launch strength visually
func update_aim_line() -> void:
	aim_line.visible = true
	aim_line.points = [Vector2.ZERO, launchDirection * chargeRatio * maxLaunchPullback]
	aim_line.default_color = lowChargeColor.lerp(highChargeColor, chargeRatio)
