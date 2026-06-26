extends CharacterBody2D
@onready var aim_line: Line2D = $AimLine
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shieldSprite: AnimatedSprite2D = $shieldSprite
var currentAnimation: String = ""

@export var lowChargeColor: Color = Color.YELLOW
@export var highChargeColor: Color = Color.RED
var currentHealthCount: int = 0

####### Upgrade Variables ########
@export var maxHealthCount: int = 3
var maxComboCount: int = 4
@export var comboVelocityMultiplier: float = 1.2
@export var bounceWindowDuration: float = 0.15 
@export var maxChargeTime: float = 2.0

####### Combo Configuration ########
@export var baseMaxVelocity: float = 600.0 
var comboCounter: int = 0
@export var comboDecayTime: float = 2.0
var comboDecayTimer = null
var maxComboVelocity: Vector2 = Vector2.ZERO

###### Launch configuration #######
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
@export var bounceCooldown: float = 2
var bounceCooldownTimer = null

var bounces: int = 0
var isBouncing: bool = false
var canBounce: bool = true

const HALT_SPEED = 1000
const SPEED = 100.0

signal hit
signal deflect
signal max_health_changed(newMax: int)

var isInvulnerable: bool = false

func _on_body_entered(_body):
	if isInvulnerable:
		return
	_hit()

func _hit() -> void:
	if isInvulnerable:
		return
		
	currentHealthCount -= 1
	#print("Hit! Health remaining: ", currentHealthCount)
	hit.emit(currentHealthCount)
	
	if currentHealthCount <= 0:
		#hide()
		hit.emit()
		$CollisionShape2D.set_deferred("disabled", true)
		return
	
	isInvulnerable = true
	await get_tree().create_timer(2.5).timeout
	isInvulnerable = false

func _deflect() -> void:
	if comboCounter < maxComboCount:
		comboCounter += 1
		velocity *= comboVelocityMultiplier
	
	deflect.emit(comboCounter)
	_resetComboDecayTimer()

func _resetComboDecayTimer() -> void:
	# Cancel existing timer if one is running
	if comboDecayTimer != null:
		comboDecayTimer.timeout.disconnect(_on_combo_decay)
	
	# Start a fresh timer
	comboDecayTimer = get_tree().create_timer(comboDecayTime)
	comboDecayTimer.timeout.connect(_on_combo_decay)

func _on_combo_decay() -> void:
	comboCounter = 0
	maxComboVelocity = Vector2.ZERO
	comboDecayTimer = null
	
	# Notify Ui to reset combo counter
	deflect.emit(comboCounter)
	
func start(pos):
	currentHealthCount = maxHealthCount
	isInvulnerable = false
	comboCounter = 0
	comboDecayTimer = null
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
	if get_tree().paused:
		return
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	#if velocity.length() < 200:
		#isLaunched = false
	
	if !isLaunched && !isCharging:
		# Normalize vectors
		var direction = input_dir.normalized() 
		
		######## Play animations 
		# Compare absolute values to see if moving more horizontally or vertically
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				playAnimation("walk_side", true) # Face Right
			else:
				playAnimation("walk_side", false) # Face Left (Mirrored)
		else:
			if velocity.y < 0:
				playAnimation("walk_up")    
			else:
				playAnimation("walk_down")   
		
		# Apply movement 
		if direction:
			velocity = direction * SPEED
		else:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)
			playAnimation("idle")
		
	if isCharging and !isLaunched:
		playAnimation("charge")
		velocity = Vector2.ZERO
		currentChargeTime += delta
		currentChargeTime = clamp(currentChargeTime, 0.0, maxChargeTime)
		chargeRatio = currentChargeTime / maxChargeTime
		
		# Use mouse for aim line direction
		launchDirection = get_local_mouse_position().normalized()
		update_aim_line()
	
	var collisionInfo = move_and_collide(velocity * delta)
	if collisionInfo and isBouncing:
		executeSuccessfulBounce(collisionInfo.get_collider(), collisionInfo)
		
	elif collisionInfo:
		handleBounce(collisionInfo)
		
	if isLaunched:
		# Only decay if below max combo
		if comboCounter < maxComboCount:
			velocity = velocity.move_toward(Vector2.ZERO, velocity.length() * (delta / launchDecay))

		if Input.is_action_pressed("halt"):
			velocity = velocity.move_toward(Vector2.ZERO, HALT_SPEED * delta)
			if abs(velocity.x) > abs(velocity.y):
				if velocity.x > 0:
					playAnimation("slide_side", true)
				else:
					playAnimation("slide_side", false)
			else:
				if velocity.y < 0:
					playAnimation("slide_up")
				else:
					playAnimation("slide_down")
		else:
			playAnimation("spin")

		if velocity.length_squared() < 5.0:
			velocity = Vector2.ZERO
			isLaunched = false
		


func _input(event):
	if get_tree().paused:
		return
	if event.is_action_pressed("charge") and !isLaunched:
		isCharging = true
		currentChargeTime = 0.0
	
	if event.is_action_released("charge") and isCharging and !isLaunched:
		isCharging = false
		launchDirection = get_local_mouse_position().normalized()
		executeLaunch()
		
	# Right click cancels charge
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if isCharging:
			isCharging = false
			currentChargeTime = 0.0
			chargeRatio = 0.0
			aim_line.visible = false
	
	if event.is_action_pressed("bounce") and canBounce:
		shieldSprite.show()
		shieldSprite.play("rebound")
		triggerBounceWindow()
		
		await shieldSprite.animation_finished
		shieldSprite.hide()
		
		
func handleBounce(collision: KinematicCollision2D) -> void:
	var obstacle = collision.get_collider()
	
	if obstacle.is_in_group("enemies"):
		if velocity.length() >= killVelocityThreshold:
			isKillingEnemy = true
			obstacle.die()
			obstacle.died.connect(func(): isKillingEnemy = false, CONNECT_ONE_SHOT)
			return
		elif velocity.length() > 200 && velocity.length() < killVelocityThreshold:
			obstacle.hit()
		elif velocity.length() < 200 && !isInvulnerable:
			#_hit()
			pass
			
		#else:
			#velocity = Vector2.ZERO
			#return
	
	var reflect = collision.get_remainder().bounce(collision.get_normal())
	## Calculate the bounce direction
	velocity = velocity.bounce(collision.get_normal())
	move_and_collide(reflect)
	
func executeLaunch() -> void:
	isCharging = false
	isLaunched = true
	var launchForce = lerp(minLaunchStrength, maxLaunchStrength, chargeRatio)
	velocity = launchDirection * launchForce
	aim_line.visible = false

func triggerBounceWindow() -> void:
	isBouncing = true
	canBounce = false
	
	for body in bounceDetector.get_overlapping_bodies():
		if isBouncing:
			executeSuccessfulBounce(body, null)
			break
	
	await get_tree().create_timer(bounceWindowDuration).timeout
	isBouncing = false
	
	print("After window, canBounce: ", canBounce)
	if not canBounce:
		_startBounceCooldown()
		
func _startBounceCooldown() -> void:
	# Cancel existing cooldown if one is running
	if bounceCooldownTimer != null:
		bounceCooldownTimer.timeout.disconnect(_on_bounce_cooldown_finished)
	
	canBounce = false
	bounceCooldownTimer = get_tree().create_timer(bounceCooldown)
	bounceCooldownTimer.timeout.connect(_on_bounce_cooldown_finished)

func _on_bounce_cooldown_finished() -> void:
	canBounce = true
	bounceCooldownTimer = null
	
func executeSuccessfulBounce(obstacle: Node2D, collision: KinematicCollision2D = null) -> bool:
	isBouncing = false
	
	if obstacle.is_in_group("enemies") && isLaunched:
		if velocity.length() >= killVelocityThreshold:
			isKillingEnemy = true
			obstacle.die()
			obstacle.died.connect(func(): isKillingEnemy = false, CONNECT_ONE_SHOT)
		else:
			obstacle.die()
	
	if collision:
		handleBounce(collision)
	
	# Cancel cooldown on successful bounce so player can chain immediately
	if bounceCooldownTimer != null:
		bounceCooldownTimer.timeout.disconnect(_on_bounce_cooldown_finished)
		bounceCooldownTimer = null
	canBounce = true
	
	_deflect()
	
	return true
	
# Temporary function to show launch strength visually
func update_aim_line() -> void:
	aim_line.visible = true
	aim_line.points = [Vector2.ZERO, launchDirection * chargeRatio * maxLaunchPullback]
	aim_line.default_color = lowChargeColor.lerp(highChargeColor, chargeRatio)

# Check if an animation is currently playing, prevents restarting the same anim each frame
func playAnimation(anim: String, flipH: bool = false) -> void:
	if currentAnimation != anim:
		currentAnimation = anim
		animatedSprite.flip_h = flipH
		animatedSprite.play(anim)
