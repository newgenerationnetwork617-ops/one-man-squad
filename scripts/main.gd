extends Node3D
## First playable foundation: compact test district, player, starter car and activity lobby.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const CAR_SCENE: PackedScene = preload("res://scenes/starter_car.tscn")

var player: CharacterBody3D
var vehicle: CharacterBody3D
var status_label: Label
var drive_button: Button
var is_driving := false
var mission_stage := 0
var pickup_area: Area3D
var delivery_area: Area3D
var mission_label: Label
var race_label: Label
var race_checkpoints: Array[Area3D] = []
var race_active := false
var race_checkpoint_index := 0
var race_elapsed := 0.0
var speed_label: Label
var competition_label: Label
var competition_objectives: Array[Area3D] = []
var competition_active := false
var competition_collected := 0
var competition_time_left := 60.0
var save_config := ConfigFile.new()
var mission_completed := false
var best_time_trial := 0.0
var completed_competition_rounds := 0
var records_label: Label

func _ready() -> void:
	_load_progress()
	_build_environment()
	_build_test_district()
	_spawn_player()
	_spawn_vehicle()
	_build_adventure_mission()
	_build_interface()

func _process(delta: float) -> void:
	if is_instance_valid(vehicle) and is_instance_valid(speed_label):
		speed_label.text = "%03d km/h" % int(absf(float(vehicle.get("current_speed"))) * 3.6)
	if race_active:
		race_elapsed += delta
		race_label.text = "TIME TRIAL  •  %05.2f s" % race_elapsed
	if competition_active:
		competition_time_left = maxf(0.0, competition_time_left - delta)
		competition_label.text = "COMPETITION  •  %d/3 SIGNALS  •  %02d s" % [competition_collected, int(ceil(competition_time_left))]
		if competition_time_left <= 0.0:
			competition_active = false
			status_label.text = "Round over • You collected %d of 3 signals." % competition_collected

func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.42, 0.62, 0.78)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.68, 0.76, 0.86)
	environment.ambient_light_energy = 0.7
	world_environment.environment = environment
	add_child(world_environment)

	var sunlight := DirectionalLight3D.new()
	sunlight.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sunlight.light_energy = 1.1
	sunlight.shadow_enabled = false
	add_child(sunlight)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material

func _add_box(parent: Node3D, box_name: String, position: Vector3, size: Vector3, color: Color, is_static: bool = false) -> void:
	var body: Node3D
	if is_static:
		body = StaticBody3D.new()
	else:
		body = Node3D.new()
	body.name = box_name
	body.position = position
	parent.add_child(body)

	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = _material(color)
	body.add_child(mesh_instance)

	if is_static:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)

func _build_test_district() -> void:
	_add_box(self, "Ground", Vector3(0, -0.25, 0), Vector3(90, 0.5, 90), Color(0.27, 0.39, 0.31), true)
	_add_box(self, "MainRoad", Vector3(0, 0.015, 0), Vector3(9, 0.04, 78), Color(0.12, 0.13, 0.15))
	_add_box(self, "CrossRoad", Vector3(0, 0.025, -8), Vector3(78, 0.04, 8), Color(0.12, 0.13, 0.15))

	var building_colors: Array[Color] = [
		Color(0.68, 0.66, 0.61), Color(0.53, 0.61, 0.66),
		Color(0.73, 0.70, 0.62), Color(0.48, 0.53, 0.57)
	]
	var building_positions: Array[Vector3] = [
		Vector3(-15, 3, -18), Vector3(15, 4, -19),
		Vector3(-18, 2.5, 7), Vector3(18, 3.5, 8),
		Vector3(-15, 3, 24), Vector3(15, 2.5, 25),
		Vector3(-29, 4, -5), Vector3(29, 3, -5)
	]
	for index in range(building_positions.size()):
		var height := building_positions[index].y * 2.0
		_add_box(self, "DistrictBuilding_%02d" % index, building_positions[index],
			Vector3(9, height, 9), building_colors[index % building_colors.size()], true)

func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate() as CharacterBody3D
	player.position = Vector3(0, 0.1, 8)
	add_child(player)

func _spawn_vehicle() -> void:
	vehicle = CAR_SCENE.instantiate() as CharacterBody3D
	vehicle.position = Vector3(2.8, 0.1, 8)
	add_child(vehicle)
	vehicle.set_physics_process(false)

func _build_interface() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	var heading := Label.new()
	heading.text = "ONE MAN SQUAD"
	heading.position = Vector2(28, 20)
	heading.add_theme_font_size_override("font_size", 28)
	heading.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(heading)

	var subheading := Label.new()
	subheading.text = "ADVENTURE  •  COMPETITION  •  RACING"
	subheading.position = Vector2(30, 58)
	subheading.add_theme_font_size_override("font_size", 13)
	subheading.add_theme_color_override("font_color", Color(0.84, 0.9, 0.95))
	root.add_child(subheading)

	var activity_box := VBoxContainer.new()
	activity_box.position = Vector2(28, 100)
	activity_box.custom_minimum_size = Vector2(230, 0)
	activity_box.add_theme_constant_override("separation", 10)
	root.add_child(activity_box)
	_add_activity_button(activity_box, "Adventure", "Complete the first supply delivery mission in the starter district.")
	_add_activity_button(activity_box, "Competition", "Challenge-zone foundation: objective-based AI rounds will be added here.")
	_add_activity_button(activity_box, "Racing", "Start a short driving time trial.")

	mission_label = Label.new()
	mission_label.text = "MISSION 01  •  Find the supply crate"
	mission_label.position = Vector2(28, 250)
	mission_label.add_theme_font_size_override("font_size", 16)
	mission_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.42))
	root.add_child(mission_label)

	status_label = Label.new()
	status_label.text = "Prototype build • Walk to the blue car and try driving."
	status_label.position = Vector2(28, 285)
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(status_label)

	race_label = Label.new()
	race_label.text = "TIME TRIAL  •  Not started"
	race_label.position = Vector2(28, 318)
	race_label.add_theme_font_size_override("font_size", 14)
	race_label.add_theme_color_override("font_color", Color(0.55, 0.9, 1.0))
	root.add_child(race_label)

	competition_label = Label.new()
	competition_label.text = "COMPETITION  •  Not started"
	competition_label.position = Vector2(28, 350)
	competition_label.add_theme_font_size_override("font_size", 14)
	competition_label.add_theme_color_override("font_color", Color(1.0, 0.68, 0.42))
	root.add_child(competition_label)

	records_label = Label.new()
	records_label.text = _records_text()
	records_label.position = Vector2(28, 382)
	records_label.add_theme_font_size_override("font_size", 13)
	records_label.add_theme_color_override("font_color", Color(0.82, 0.88, 0.92))
	root.add_child(records_label)

	speed_label = Label.new()
	speed_label.text = "000 km/h"
	speed_label.anchor_left = 1.0
	speed_label.anchor_right = 1.0
	speed_label.offset_left = -190
	speed_label.offset_right = -28
	speed_label.offset_top = 92
	speed_label.offset_bottom = 126
	speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	speed_label.add_theme_font_size_override("font_size", 22)
	speed_label.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(speed_label)

	drive_button = Button.new()
	drive_button.text = "ENTER CAR"
	drive_button.anchor_left = 1.0
	drive_button.anchor_right = 1.0
	drive_button.offset_left = -190
	drive_button.offset_right = -28
	drive_button.offset_top = 28
	drive_button.offset_bottom = 82
	drive_button.pressed.connect(_toggle_vehicle)
	root.add_child(drive_button)

	_add_touch_button(root, "↑", Vector2(112, -150), "move_forward")
	_add_touch_button(root, "↓", Vector2(112, -58), "move_back")
	_add_touch_button(root, "←", Vector2(18, -104), "move_left")
	_add_touch_button(root, "→", Vector2(206, -104), "move_right")
	_add_brake_button(root)

func _build_adventure_mission() -> void:
	# A small, safe delivery mission introduces exploration and navigation.
	pickup_area = _create_mission_area("SupplyCratePickup", Vector3(-3.0, 0.0, 8.0), Color(1.0, 0.72, 0.22))
	var crate := MeshInstance3D.new()
	var crate_mesh := BoxMesh.new()
	crate_mesh.size = Vector3(0.9, 0.75, 0.9)
	crate.mesh = crate_mesh
	crate.material_override = _material(Color(0.72, 0.43, 0.19))
	crate.position = Vector3(-3.0, 0.42, 8.0)
	add_child(crate)

	delivery_area = _create_mission_area("DeliveryDestination", Vector3(0.0, 0.0, -28.0), Color(0.25, 0.9, 0.55))
	delivery_area.visible = false
	delivery_area.monitoring = false
	delivery_area.monitorable = false

func _create_mission_area(area_name: String, target_position: Vector3, marker_color: Color) -> Area3D:
	var area := Area3D.new()
	area.name = area_name
	area.position = target_position
	add_child(area)

	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 2.2
	shape.height = 2.5
	collision.shape = shape
	collision.position.y = 1.25
	area.add_child(collision)

	var beacon := MeshInstance3D.new()
	var beacon_mesh := CylinderMesh.new()
	beacon_mesh.top_radius = 0.12
	beacon_mesh.bottom_radius = 0.12
	beacon_mesh.height = 3.0
	beacon.mesh = beacon_mesh
	var beacon_material := _material(marker_color)
	beacon_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beacon_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beacon_material.albedo_color = Color(marker_color.r, marker_color.g, marker_color.b, 0.72)
	beacon.material_override = beacon_material
	beacon.position.y = 1.5
	area.add_child(beacon)

	var ring := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 1.7
	ring_mesh.outer_radius = 2.0
	ring.mesh = ring_mesh
	ring.material_override = beacon_material
	ring.position.y = 0.12
	area.add_child(ring)

	area.body_entered.connect(_on_mission_area_entered.bind(area))
	return area

func _on_mission_area_entered(body: Node3D, area: Area3D) -> void:
	if body != player and body != vehicle:
		return
	if area == pickup_area and mission_stage == 0:
		mission_stage = 1
		pickup_area.queue_free()
		mission_label.text = "MISSION 01  •  Deliver the supply crate"
		delivery_area.visible = true
		delivery_area.monitoring = true
		delivery_area.monitorable = true
		status_label.text = "Supply collected • Follow the green marker down the main road."
	elif area == delivery_area and mission_stage == 1:
		mission_stage = 2
		delivery_area.queue_free()
		mission_label.text = "MISSION 01  •  COMPLETE"
		mission_completed = true
		_save_progress()
		status_label.text = "Delivery completed • First mission reward: 100 XP"

func _toggle_vehicle() -> void:
	if not is_driving:
		if player.global_position.distance_to(vehicle.global_position) > 4.5:
			status_label.text = "Walk closer to the blue car before entering."
			return
		is_driving = true
		player.set_physics_process(false)
		player.visible = false
		player.get_node("CollisionShape3D").set_deferred("disabled", true)
		player.get_node("CameraPivot/Camera3D").current = false
		vehicle.get_node("CameraPivot/Camera3D").current = true
		vehicle.set_physics_process(true)
		drive_button.text = "EXIT CAR"
		status_label.text = "Driving mode • Use the arrows to steer and accelerate."
	else:
		is_driving = false
		player.global_position = vehicle.global_position + vehicle.global_basis.x * 2.5
		player.rotation.y = vehicle.rotation.y
		player.visible = true
		player.get_node("CollisionShape3D").set_deferred("disabled", false)
		player.get_node("CameraPivot/Camera3D").current = true
		vehicle.get_node("CameraPivot/Camera3D").current = false
		vehicle.set_physics_process(false)
		vehicle.velocity = Vector3.ZERO
		drive_button.text = "ENTER CAR"
		status_label.text = "On foot • Explore the starter district."

func _start_time_trial() -> void:
	if not is_driving:
		status_label.text = "Enter the blue car first, then select Racing to begin the time trial."
		return
	if race_active:
		status_label.text = "Time trial already in progress • Pass the glowing checkpoints in order."
		return
	race_active = true
	race_elapsed = 0.0
	race_checkpoint_index = 0
	for checkpoint in race_checkpoints:
		if is_instance_valid(checkpoint):
			checkpoint.queue_free()
	race_checkpoints.clear()
	var checkpoint_positions: Array[Vector3] = [
		Vector3(0.0, 0.0, -3.0),
		Vector3(0.0, 0.0, -16.0),
		Vector3(0.0, 0.0, -29.0),
		Vector3(0.0, 0.0, -37.0)
	]
	for index in range(checkpoint_positions.size()):
		var marker_color := Color(0.2, 0.85, 1.0) if index < checkpoint_positions.size() - 1 else Color(1.0, 0.82, 0.2)
		var checkpoint := _create_race_checkpoint(index, checkpoint_positions[index], marker_color)
		race_checkpoints.append(checkpoint)
	race_label.text = "TIME TRIAL  •  00.00 s"
	status_label.text = "Checkpoint 1 of 4 • Drive through each glowing marker in order."

func _create_race_checkpoint(index: int, target_position: Vector3, marker_color: Color) -> Area3D:
	var area := Area3D.new()
	area.name = "RaceCheckpoint_%02d" % index
	area.position = target_position
	add_child(area)
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 3.4
	shape.height = 3.0
	collision.shape = shape
	collision.position.y = 1.5
	area.add_child(collision)
	var ring := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 2.6
	ring_mesh.outer_radius = 2.9
	ring_mesh.rings = 8
	ring_mesh.ring_segments = 16
	ring.mesh = ring_mesh
	var material := _material(marker_color)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = material
	ring.position.y = 1.0
	area.add_child(ring)
	area.body_entered.connect(_on_race_checkpoint_entered.bind(index))
	return area

func _on_race_checkpoint_entered(body: Node3D, index: int) -> void:
	if body != vehicle or not race_active or index != race_checkpoint_index:
		return
	race_checkpoints[index].queue_free()
	race_checkpoint_index += 1
	if race_checkpoint_index >= race_checkpoints.size():
		race_active = false
		var new_record := best_time_trial <= 0.0 or race_elapsed < best_time_trial
		if new_record:
			best_time_trial = race_elapsed
			_save_progress()
		race_label.text = "TIME TRIAL  •  FINISHED  •  %05.2f s" % race_elapsed
		if new_record:
			status_label.text = "New personal best! Your time is saved on this device."
		else:
			status_label.text = "Time trial complete • Your result is shown above."
		records_label.text = _records_text()
	else:
		status_label.text = "Checkpoint %d of %d • Keep following the road." % [race_checkpoint_index + 1, race_checkpoints.size()]

func _add_activity_button(parent: VBoxContainer, title: String, description: String) -> void:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(220, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if title == "Racing":
		button.pressed.connect(_start_time_trial)
	elif title == "Competition":
		button.pressed.connect(_start_competition_round)
	else:
		button.pressed.connect(func() -> void:
			status_label.text = description
		)
	parent.add_child(button)

func _add_touch_button(parent: Control, symbol: String, offset: Vector2, action_name: String) -> void:
	var button := Button.new()
	button.text = symbol
	button.custom_minimum_size = Vector2(76, 76)
	button.anchor_left = 0.0
	button.anchor_top = 1.0
	button.anchor_right = 0.0
	button.anchor_bottom = 1.0
	button.offset_left = offset.x
	button.offset_top = offset.y
	button.offset_right = offset.x + 76
	button.offset_bottom = offset.y + 76
	button.add_theme_font_size_override("font_size", 24)
	button.button_down.connect(func() -> void:
		Input.action_press(action_name)
	)
	button.button_up.connect(func() -> void:
		Input.action_release(action_name)
	)
	parent.add_child(button)

func _add_brake_button(parent: Control) -> void:
	var button := Button.new()
	button.text = "BRAKE"
	button.custom_minimum_size = Vector2(112, 68)
	button.anchor_left = 1.0
	button.anchor_top = 1.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = -150
	button.offset_top = -100
	button.offset_right = -28
	button.offset_bottom = -24
	button.add_theme_font_size_override("font_size", 18)
	button.button_down.connect(func() -> void:
		Input.action_press("vehicle_brake")
	)
	button.button_up.connect(func() -> void:
		Input.action_release("vehicle_brake")
	)
	parent.add_child(button)

func _start_competition_round() -> void:
	if is_driving:
		status_label.text = "Exit the car before starting the on-foot signal challenge."
		return
	if competition_active:
		status_label.text = "Competition round is already active • Collect the glowing signals."
		return
	for objective in competition_objectives:
		if is_instance_valid(objective):
			objective.queue_free()
	competition_objectives.clear()
	competition_active = true
	competition_collected = 0
	competition_time_left = 60.0
	var targets: Array[Vector3] = [
		Vector3(0.0, 0.0, -10.0),
		Vector3(0.0, 0.0, -22.0),
		Vector3(0.0, 0.0, -34.0)
	]
	for index in range(targets.size()):
		competition_objectives.append(_create_competition_objective(index, targets[index]))
	competition_label.text = "COMPETITION  •  0/3 SIGNALS  •  60 s"
	status_label.text = "Signal challenge started • Collect all three glowing markers before time runs out."

func _create_competition_objective(index: int, target_position: Vector3) -> Area3D:
	var area := Area3D.new()
	area.name = "CompetitionSignal_%02d" % index
	area.position = target_position
	add_child(area)
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 2.0
	shape.height = 2.5
	collision.shape = shape
	collision.position.y = 1.25
	area.add_child(collision)
	var beacon := MeshInstance3D.new()
	var beacon_mesh := CylinderMesh.new()
	beacon_mesh.top_radius = 0.18
	beacon_mesh.bottom_radius = 0.18
	beacon_mesh.height = 2.4
	beacon.mesh = beacon_mesh
	var material := _material(Color(1.0, 0.42, 0.18))
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beacon.material_override = material
	beacon.position.y = 1.2
	area.add_child(beacon)
	var ring := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 1.5
	ring_mesh.outer_radius = 1.8
	ring.mesh = ring_mesh
	ring.material_override = material
	ring.position.y = 0.12
	area.add_child(ring)
	area.body_entered.connect(_on_competition_objective_entered.bind(index))
	return area

func _on_competition_objective_entered(body: Node3D, index: int) -> void:
	if body != player or not competition_active:
		return
	if index != competition_collected:
		status_label.text = "Collect the signals in numbered order."
		return
	competition_objectives[index].queue_free()
	competition_collected += 1
	if competition_collected >= 3:
		competition_active = false
		completed_competition_rounds += 1
		_save_progress()
		competition_label.text = "COMPETITION  •  ROUND COMPLETE"
		status_label.text = "Challenge complete • All three signals collected."
		records_label.text = _records_text()
	else:
		status_label.text = "Signal secured • %d of 3 collected." % competition_collected

func _load_progress() -> void:
	var error := save_config.load("user://progress.cfg")
	if error != OK:
		return
	mission_completed = bool(save_config.get_value("progress", "mission_completed", false))
	best_time_trial = float(save_config.get_value("records", "best_time_trial", 0.0))
	completed_competition_rounds = int(save_config.get_value("records", "competition_rounds", 0))

func _save_progress() -> void:
	save_config.set_value("progress", "mission_completed", mission_completed)
	save_config.set_value("records", "best_time_trial", best_time_trial)
	save_config.set_value("records", "competition_rounds", completed_competition_rounds)
	var error := save_config.save("user://progress.cfg")
	if error != OK:
		push_warning("Could not save local progress. Error code: %s" % error)

func _records_text() -> String:
	var mission_text := "Delivery: COMPLETE" if mission_completed else "Delivery: Not completed"
	var time_text := "Best time: --" if best_time_trial <= 0.0 else "Best time: %05.2f s" % best_time_trial
	return "LOCAL PROGRESS  •  %s  •  %s  •  Competition rounds: %d" % [mission_text, time_text, completed_competition_rounds]
