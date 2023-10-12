extends Control

var current_health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("attack"):
		current_health -= 10
	#$HealthBar.custom_minimum_size((current_health/100 * 500), 50)
