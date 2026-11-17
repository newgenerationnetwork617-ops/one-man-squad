extends CharacterBody3D
## Lightweight camera-relative third-person controller for the mobile prototype.

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var gravity: float = 18.0
@export var look_sensitivity: float = 0.0045
@export var min_look_angle: float = -0.55
@export var max_look_angle: float = 0.28

@onready var camera_pivot: Node3D = $CameraPivot

func _unhandled_input(event: InputEvent) -> void:
	var viewport_width := get_viewport().get_visible_rect().size.x

	# Reserve the right half of the screen for camera swipes so the
	# left-side movement buttons remain easy to use.
	if event is InputEventScreenDrag:
		if event.position.x >= viewport_width * 0.45:
			_rotate_camera(event.relative)
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event.position.x >= viewport_width * 0.45:
			_rotate_camera(event.relative)

func _rotate_camera(relative_motion: Vector2) -> void:
	camera_pivot.rotation.y -= relative_motion.x * look_sensitivity
	camera_pivot.rotation.x = clampf(
		camera_pivot.rotation.x - relative_motion.y * look_sensitivity,
		min_look_angle,
		max_look_angle
	)

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
