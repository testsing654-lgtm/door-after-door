extends CharacterBody3D

@export_group("Player sittings")
@export var Speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var mouse_sensivity: float = 0.004
@export var touch_sensivity: float = 0.005
@export var gravity: float = 9.8

@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D

var target_velocity = Vector3.ZERO
var head_bob_time = 0.0
var is_mouse_captured = false

var touch_start_pos = Vector2.ZERO
var is_swiping = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	is_mouse_captured = true
	pass

func _input(event):
	if event is InputEventMouseMotion and is_mouse_captured:
		rotate_y(-event.relative.x * mouse_sensivity)
		head.rotate_x(-event.relative.y * mouse_sensivity)
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position
			is_swiping = true
		else:
			is_swiping = false
	
	if event is InputEventScreenDrag and is_swiping:
		var delta = event.position - touch_start_pos
		rotate_y(-delta.x * touch_sensivity)
		head.rotate_x(-delta.y * touch_sensivity)
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)
		touch_start_pos = event.position
	if event.is_action_pressed("ui_cancel"):
		if is_mouse_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			is_mouse_captured = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			is_mouse_captured = true
	pass

func _physics_process(delta):
	var direction = Vector3.ZERO
	
	var input_dir = Input.get_vector("a", "d", "w", "s")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var currect_speed = Speed
	if Input.is_action_just_pressed("Shift"):
		currect_speed = sprint_speed
	
	target_velocity.x = direction.x * currect_speed
	target_velocity.z = direction.z * currect_speed
	
	if not is_on_floor():
		target_velocity.y -= gravity * delta
	if Input.is_action_just_pressed("Space") and is_on_floor():
		target_velocity.y = jump_velocity
	
	velocity = target_velocity
	move_and_slide()
	
	var velocity_flat = Vector2(velocity.x, velocity.z).length()
	if is_on_floor() and velocity_flat > 0.5:
		head_bob_time += delta * velocity_flat * 0.3
		camera_3d.transform.origin.y = sin(head_bob_time) * 0.05
	else:
		camera_3d.transform.origin.y = lerp(camera_3d.transform.origin.y, 0.0, delta * 10.0)
	pass
