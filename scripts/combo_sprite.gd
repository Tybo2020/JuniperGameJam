extends Panel
@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update(comboCount: int):
	match comboCount:
		# Replace with updating the sprite frame
		0: print ("D")
		1: print("C")
		2: print("B")
		3: print("A")
		4: print("S")
		5: print("SS")
		6: print("SSS")
