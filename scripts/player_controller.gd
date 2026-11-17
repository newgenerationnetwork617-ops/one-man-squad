extends CharacterBody3D
## Camera-relative mobile character controller with lightweight procedural walk animation.
@export var move_speed: float = 5.2
@export var acceleration: float = 20.0
@export var gravity: float = 18.0
@export var look_sensitivity: float = 0.006
@export var min_look_angle: float = -0.48
@export var max_look_angle: float = 0.24
@onready var camera_pivot: Node3D = $CameraPivot
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var torso: Node3D
var animation_clock := 0.0

func _ready() -> void:
	left_arm = get_node_or_null("LeftArm")
	right_arm = get_node_or_null("RightArm")
	left_leg = get_node_or_null("LeftLeg")
	right_leg = get_node_or_null("RightLeg")
	torso = get_node_or_null("Torso")

func _input(event: InputEvent) -> void:
	var width := get_viewport().get_visible_rect().size.x
	if event is InputEventScreenDrag and event.position.x >= width * 0.38:
		_rotate_camera(event.relative)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event.position.x >= width * 0.38:
		_rotate_camera(event.relative)

func _rotate_camera(relative_motion: Vector2) -> void:
	camera_pivot.rotation.y -= relative_motion.x * look_sensitivity
	camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - relative_motion.y * look_sensitivity, min_look_angle, max_look_angle)

func reset_camera() -> void:
	camera_pivot.rotation = Vector3(-0.12, 0.0, 0.0)

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := -camera_pivot.global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := camera_pivot.global_basis.x
	right.y = 0.0
	right = right.normalized()
	var direction := right * input_vector.x + forward * -input_vector.y
	if direction.length_squared() > 0.001:
		direction = direction.normalized()
		velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	_animate_character(delta)

func _animate_character(delta: float) -> void:
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var moving := horizontal_speed > 0.25 and is_on_floor()
	animation_clock += delta * (8.0 if moving else 2.0)
	var stride := sin(animation_clock) * (0.48 if moving else 0.025)
	if is_instance_valid(left_leg):
		left_leg.rotation.x = stride
	if is_instance_valid(right_leg):
		right_leg.rotation.x = -stride
	if is_instance_valid(left_arm):
		left_arm.rotation.x = -stride * 0.72
	if is_instance_valid(right_arm):
		right_arm.rotation.x = stride * 0.72
	if is_instance_valid(torso):
		torso.position.y = 1.12 + (absf(sin(animation_clock * 2.0)) * 0.025 if moving else sin(animation_clock) * 0.008)
