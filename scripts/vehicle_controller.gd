extends CharacterBody3D
## Lightweight arcade vehicle controller with a separate right-side camera drag zone.
@export var acceleration: float = 10.0
@export var reverse_acceleration: float = 6.0
@export var max_speed: float = 17.0
@export var reverse_speed: float = 6.0
@export var braking: float = 20.0
@export var steering_speed: float = 1.7
@export var gravity: float = 18.0
@export var look_sensitivity: float = 0.006
@onready var camera_pivot: Node3D = $CameraPivot
var current_speed: float = 0.0

func _input(event: InputEvent) -> void:
	var width := get_viewport().get_visible_rect().size.x
	if event is InputEventScreenDrag and event.position.x >= width * 0.38:
		_rotate_camera(event.relative)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event.position.x >= width * 0.38:
		_rotate_camera(event.relative)

func _rotate_camera(relative_motion: Vector2) -> void:
	camera_pivot.rotation.y -= relative_motion.x * look_sensitivity
	camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - relative_motion.y * look_sensitivity, -0.42, 0.18)

func reset_camera() -> void:
	camera_pivot.rotation = Vector3(-0.12, 0.0, 0.0)

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if Input.is_action_pressed("vehicle_brake"):
		current_speed = move_toward(current_speed, 0.0, braking * delta)
	elif input_vector.y < -0.05:
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	elif input_vector.y > 0.05:
		current_speed = move_toward(current_speed, -reverse_speed, reverse_acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, braking * 0.35 * delta)
	if absf(current_speed) > 0.15:
		var steering_direction := signf(current_speed)
		rotation.y -= input_vector.x * steering_speed * steering_direction * delta * clampf(absf(current_speed) / 5.0, 0.25, 1.0)
	var forward := -global_basis.z
	velocity.x = forward.x * current_speed
	velocity.z = forward.z * current_speed
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	if is_on_wall():
		current_speed *= 0.35
