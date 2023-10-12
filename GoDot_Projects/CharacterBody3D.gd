extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var sensitivity = 250
var hit_top = 0
var walk_top = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func leg_movement(WALK_RATE, delta, mode):
	if mode == "reset" and $LeftLegPivot.rotation.x > WALK_RATE * delta:
		$LeftLegPivot.rotation.x -= WALK_RATE * delta
		$RightLegPivot.rotation.x += WALK_RATE * delta
	elif mode == "reset" and $LeftLegPivot.rotation.x < -WALK_RATE * delta:
		$LeftLegPivot.rotation.x += WALK_RATE * delta
		$RightLegPivot.rotation.x -= WALK_RATE * delta
	elif mode == "reset":
		$LeftLegPivot.rotation.x = 0
		$RightLegPivot.rotation.x = 0
	else:
		if $LeftLegPivot.rotation.x <= deg_to_rad(45) and walk_top == false and is_on_floor():
			$LeftLegPivot.rotation.x += WALK_RATE * delta
			$RightLegPivot.rotation.x -= WALK_RATE * delta
		elif $LeftLegPivot.rotation.x >= deg_to_rad(-45) and walk_top == true and is_on_floor():
			$LeftLegPivot.rotation.x -= WALK_RATE * delta
			$RightLegPivot.rotation.x += WALK_RATE * delta
		elif $LeftLegPivot.rotation.x >= deg_to_rad(45):walk_top = true
		elif $LeftLegPivot.rotation.x <= deg_to_rad(-45):walk_top = false

func right_arm_attack(ATTACK_RATE, delta, mode):
	if Input.is_action_just_pressed("attack") or hit_top != 0:
		if $RightArmPivot.rotation.x < deg_to_rad(90) and hit_top == 1:
			$RightArmPivot/RightElbowPivot.rotation.x += ATTACK_RATE * delta
			$RightArmPivot.rotation.x += ATTACK_RATE * delta
		elif $RightArmPivot.rotation.x > deg_to_rad(0) and hit_top == -1:
			$RightArmPivot.rotation.x -= ATTACK_RATE*2 * delta
			$RightArmPivot/RightElbowPivot.rotation.x -= ATTACK_RATE*2 * delta
		elif $RightArmPivot.rotation.x <= 0 and hit_top != -1: hit_top = 1
		elif $RightArmPivot.rotation.x >= deg_to_rad(90): hit_top = -1
		else: 
			hit_top = 0
			#$RightArmPivot/RightElbowPivot.rotation.x = deg_to_rad(90)
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	print(name)

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.		
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif is_on_floor() == false:leg_movement(deg_to_rad(180), delta, "reset")
		
	right_arm_attack(deg_to_rad(360), delta, "punch")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if Input.is_action_pressed("activate_sprint"):
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			leg_movement(deg_to_rad(360), delta, "sprint")
		else:
			velocity.x = direction.x * SPEED/2
			velocity.z = direction.z * SPEED/2
			leg_movement(deg_to_rad(180), delta, "walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		leg_movement(deg_to_rad(180), delta, "reset")

	move_and_slide()

func _input(event):
	#if game_has started then capture the mouse
	if not is_multiplayer_authority(): return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / sensitivity
		
		$CameraPivot.rotation.x -= event.relative.y / sensitivity
		$CameraPivot.rotation.x = clamp($CameraPivot.rotation.x, deg_to_rad(-45), deg_to_rad(90))
