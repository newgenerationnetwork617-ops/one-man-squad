extends CharacterBody3D
## Lightweight third-person controller for the first mobile prototype.

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var gravity: float = 18.0

@onready var camera_pivot: Node3D = $CameraPivot

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)

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
