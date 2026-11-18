extends Node3D
## First playable foundation: compact test district, player, starter car and activity lobby.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const CAR_SCENE: PackedScene = preload("res://scenes/starter_car.tscn")
const SPORT_CAR_SCENE: PackedScene = preload("res://scenes/sport_car.tscn")

var player: CharacterBody3D
var vehicle: CharacterBody3D
var status_label: Label
var drive_button: Button
var jump_button: Button
var brake_button: Button
var vehicle_select_button: Button
var vehicle_variant := 0
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
var mission_two_completed := false
var mission_two_active := false
var mission_two_index := 0
var mission_two_areas: Array[Area3D] = []
var total_xp := 0
var mission_two_label: Label
var xp_label: Label
var pause_panel: Control
var ui_canvas: CanvasLayer
var hud_root: Control
var home_overlay: Control
var menu_camera: Camera3D
var best_time_trial := 0.0
var completed_competition_rounds := 0
var records_label: Label
const PLAYER_SPAWN := Vector3(0.0, 0.15, 8.0)
const VEHICLE_SPAWN := Vector3(2.8, 0.15, 8.0)
const WORLD_LIMIT := 96.0

func _ready() -> void:
	_load_progress()
	_build_environment()
	_build_test_district()
	_build_park_plaza()
	_spawn_player()
	_spawn_vehicle()
	var saved_sensitivity := float(save_config.get_value("settings", "camera_sensitivity", 0.006))
	player.set("look_sensitivity", saved_sensitivity)
	vehicle.set("look_sensitivity", saved_sensitivity)
	_build_adventure_mission()
	_build_interface()
	_create_menu_camera()
	_show_home_menu()

func _process(delta: float) -> void:
	_recover_if_out_of_bounds()
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
			for objective in competition_objectives:
				if is_instance_valid(objective):
					objective.queue_free()
			competition_objectives.clear()
			competition_label.text = "COMPETITION  •  ROUND OVER"
			status_label.text = "Round over • You collected %d of 3 signals." % competition_collected

func _create_menu_camera() -> void:
	menu_camera = Camera3D.new()
	menu_camera.name = "MenuCamera"
	menu_camera.position = Vector3(18.0, 13.0, 22.0)
	menu_camera.look_at(Vector3(0.0, 1.0, -8.0), Vector3.UP)
	menu_camera.current = true
	add_child(menu_camera)

func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.12, 0.28, 0.48)
	sky_material.sky_horizon_color = Color(0.72, 0.78, 0.84)
	sky_material.ground_bottom_color = Color(0.12, 0.16, 0.14)
	sky_material.ground_horizon_color = Color(0.48, 0.54, 0.52)
	sky.sky_material = sky_material
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.78
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.62, 0.7, 0.76)
	environment.fog_density = 0.0012
	world_environment.environment = environment
	add_child(world_environment)

	var sunlight := DirectionalLight3D.new()
	sunlight.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sunlight.light_energy = 1.25
	sunlight.shadow_enabled = true
	add_child(sunlight)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	material.metallic = 0.02
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
	_add_box(self, "Ground", Vector3(0, -0.25, 0), Vector3(200, 0.5, 200), Color(0.24, 0.42, 0.29), true)
	_add_box(self, "MainRoad", Vector3(0, 0.015, 0), Vector3(10, 0.04, 190), Color(0.12, 0.13, 0.15))
	_add_box(self, "CrossRoad", Vector3(0, 0.025, -8), Vector3(190, 0.04, 10), Color(0.12, 0.13, 0.15))
	_add_box(self, "EastRoad", Vector3(34, 0.02, 20), Vector3(8, 0.04, 150), Color(0.14, 0.15, 0.16))
	_add_box(self, "WestRoad", Vector3(-34, 0.02, 20), Vector3(8, 0.04, 150), Color(0.14, 0.15, 0.16))
	_add_box(self, "NorthRoad", Vector3(0, 0.02, -48), Vector3(150, 0.04, 8), Color(0.14, 0.15, 0.16))
	_add_box(self, "SouthRoad", Vector3(0, 0.02, 48), Vector3(150, 0.04, 8), Color(0.14, 0.15, 0.16))
	for edge in [-99.0, 99.0]:
		_add_box(self, "BoundaryA_%s" % str(edge), Vector3(0, 1.5, edge), Vector3(200, 3, 1), Color(0.22, 0.3, 0.25), true)
		_add_box(self, "BoundaryB_%s" % str(edge), Vector3(edge, 1.5, 0), Vector3(1, 3, 200), Color(0.22, 0.3, 0.25), true)

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
	_build_street_details()

func _build_park_plaza() -> void:
	_add_box(self, "ParkPlazaGround", Vector3(0, 0.025, 72), Vector3(54, 0.08, 34), Color(0.34, 0.48, 0.32))
	_add_box(self, "PlazaWalkway", Vector3(0, 0.08, 72), Vector3(5, 0.12, 30), Color(0.68, 0.66, 0.58))
	_add_box(self, "PlazaCrossPath", Vector3(0, 0.09, 72), Vector3(48, 0.12, 4), Color(0.68, 0.66, 0.58))
	_add_box(self, "PlazaFountainBase", Vector3(0, 0.35, 72), Vector3(4.2, 0.55, 4.2), Color(0.42, 0.53, 0.58))
	_add_box(self, "PlazaFountainWater", Vector3(0, 0.66, 72), Vector3(3.4, 0.08, 3.4), Color(0.22, 0.58, 0.72))
	for x in [-20.0, 20.0]:
		for z in [62.0, 82.0]:
			_add_tree(Vector3(x, 0.0, z), 1.1)
	for x in [-12.0, 12.0]:
		_add_box(self, "PlazaBenchSeat", Vector3(x, 0.65, 72), Vector3(3.0, 0.18, 0.75), Color(0.38, 0.24, 0.13))
		_add_box(self, "PlazaBenchLegs", Vector3(x, 0.35, 72), Vector3(0.22, 0.6, 0.55), Color(0.18, 0.19, 0.2))

func _add_tree(tree_position: Vector3, scale_factor: float = 1.0) -> void:
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.16 * scale_factor
	trunk_mesh.bottom_radius = 0.24 * scale_factor
	trunk_mesh.height = 2.2 * scale_factor
	trunk.mesh = trunk_mesh
	trunk.material_override = _material(Color(0.28, 0.19, 0.12))
	trunk.position = tree_position + Vector3(0, 1.1 * scale_factor, 0)
	add_child(trunk)

	var canopy := MeshInstance3D.new()
	var canopy_mesh := SphereMesh.new()
	canopy_mesh.radius = 1.05 * scale_factor
	canopy_mesh.height = 2.0 * scale_factor
	canopy.mesh = canopy_mesh
	canopy.material_override = _material(Color(0.12, 0.34, 0.18))
	canopy.position = tree_position + Vector3(0, 2.55 * scale_factor, 0)
	add_child(canopy)

func _add_streetlight(light_position: Vector3) -> void:
	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.07
	pole_mesh.bottom_radius = 0.1
	pole_mesh.height = 5.2
	pole.mesh = pole_mesh
	pole.material_override = _material(Color(0.16, 0.18, 0.2))
	pole.position = light_position + Vector3(0, 2.6, 0)
	add_child(pole)
	_add_box(self, "StreetlightArm", light_position + Vector3(0.55, 5.05, 0), Vector3(1.15, 0.09, 0.09), Color(0.16, 0.18, 0.2))
	var lamp := MeshInstance3D.new()
	var lamp_mesh := SphereMesh.new()
	lamp_mesh.radius = 0.19
	lamp_mesh.height = 0.22
	lamp.mesh = lamp_mesh
	var lamp_material := _material(Color(1.0, 0.83, 0.48))
	lamp_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lamp.material_override = lamp_material
	lamp.position = light_position + Vector3(1.02, 4.92, 0)
	add_child(lamp)

func _build_street_details() -> void:
	var road_paint := Color(0.82, 0.82, 0.72)
	var curb_color := Color(0.48, 0.5, 0.48)
	# Painted centre dashes and road-edge lines.
	for z in range(-88, 89, 12):
		_add_box(self, "MainRoadDash", Vector3(0, 0.055, float(z)), Vector3(0.16, 0.025, 5.0), road_paint)
		_add_box(self, "CrossRoadDash", Vector3(float(z), 0.055, -8), Vector3(5.0, 0.025, 0.16), road_paint)
	for z in [-88.0, 88.0]:
		_add_box(self, "MainRoadEdge", Vector3(-4.55, 0.055, z), Vector3(0.12, 0.025, 18.0), curb_color)
		_add_box(self, "MainRoadEdge", Vector3(4.55, 0.055, z), Vector3(0.12, 0.025, 18.0), curb_color)
	# Low-cost sidewalks and landscaped verges around the starter blocks.
	for side in [-1.0, 1.0]:
		_add_box(self, "MainSidewalk", Vector3(side * 7.0, 0.02, 0), Vector3(2.0, 0.12, 190.0), Color(0.52, 0.53, 0.5))
		_add_box(self, "CrossSidewalk", Vector3(0, 0.02, -15.0), Vector3(190.0, 0.12, 2.0), Color(0.52, 0.53, 0.5))
	# Facade windows, roof trims and storefront bands.
	var facade_positions: Array[Vector3] = [
		Vector3(-15, 3, -18), Vector3(15, 4, -19),
		Vector3(-18, 2.5, 7), Vector3(18, 3.5, 8),
		Vector3(-15, 3, 24), Vector3(15, 2.5, 25),
		Vector3(-29, 4, -5), Vector3(29, 3, -5)
	]
	var glass := Color(0.12, 0.25, 0.34)
	for index in range(facade_positions.size()):
		var building_position: Vector3 = facade_positions[index]
		var height := building_position.y * 2.0
		for floor_index in range(maxi(1, int(height / 2.5))):
			for window_index in range(2):
				var window_x := building_position.x + (float(window_index) - 0.5) * 3.2
				var window_y := 1.2 + float(floor_index) * 2.35
				_add_box(self, "FacadeWindow", Vector3(window_x, window_y, building_position.z - 4.56), Vector3(1.25, 0.9, 0.08), glass)
		_add_box(self, "RoofTrim", Vector3(building_position.x, height + 0.12, building_position.z), Vector3(9.25, 0.24, 9.25), Color(0.28, 0.3, 0.31))
		_add_box(self, "StorefrontBand", Vector3(building_position.x, 0.85, building_position.z - 4.62), Vector3(8.8, 0.28, 0.12), Color(0.78, 0.55, 0.24))
	# Trees and lights are placed away from the road lanes.
	for z in [-38.0, -22.0, 2.0, 20.0, 38.0, 62.0]:
		_add_tree(Vector3(-10.0, 0.0, z), 0.9)
		_add_tree(Vector3(10.0, 0.0, z), 0.9)
	for z in [-42.0, -10.0, 22.0, 54.0]:
		_add_streetlight(Vector3(-5.8, 0.0, z))
		_add_streetlight(Vector3(5.8, 0.0, z))

func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate() as CharacterBody3D
	player.position = PLAYER_SPAWN
	add_child(player)

func _spawn_vehicle() -> void:
	vehicle = CAR_SCENE.instantiate() as CharacterBody3D
	vehicle.position = VEHICLE_SPAWN
	add_child(vehicle)
	vehicle.set_physics_process(false)

func _recover_if_out_of_bounds() -> void:
	if is_instance_valid(player) and (player.global_position.y < -3.0 or absf(player.global_position.x) > WORLD_LIMIT or absf(player.global_position.z) > WORLD_LIMIT):
		player.global_position = PLAYER_SPAWN
		player.velocity = Vector3.ZERO
		player.reset_camera()
		status_label.text = "Returned to the safe starting area."
	if is_instance_valid(vehicle) and (vehicle.global_position.y < -3.0 or absf(vehicle.global_position.x) > WORLD_LIMIT or absf(vehicle.global_position.z) > WORLD_LIMIT):
		vehicle.global_position = VEHICLE_SPAWN
		vehicle.rotation = Vector3.ZERO
		vehicle.velocity = Vector3.ZERO
		vehicle.current_speed = 0.0
		vehicle.reset_camera()
		status_label.text = "Vehicle recovered to the starting area."

func _build_interface() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	ui_canvas = canvas
	add_child(canvas)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_root = root
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
	_add_activity_button(activity_box, "Mission 02", "Collect three supply caches around the new park plaza.")
	_add_activity_button(activity_box, "Competition", "Challenge-zone foundation: objective-based AI rounds will be added here.")
	_add_activity_button(activity_box, "Racing", "Start a short driving time trial.")

	mission_label = Label.new()
	mission_label.text = "MISSION 01  •  COMPLETE" if mission_completed else "MISSION 01  •  Find the supply crate"
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

	mission_two_label = Label.new()
	mission_two_label.text = "MISSION 02  •  COMPLETE" if mission_two_completed else ("MISSION 02  •  Ready at the park plaza" if mission_completed else "MISSION 02  •  Locked until Mission 01")
	mission_two_label.position = Vector2(28, 410)
	mission_two_label.add_theme_font_size_override("font_size", 13)
	mission_two_label.add_theme_color_override("font_color", Color(0.68, 0.94, 0.72))
	root.add_child(mission_two_label)

	xp_label = Label.new()
	xp_label.text = "XP  •  %d" % total_xp
	xp_label.position = Vector2(28, 434)
	xp_label.add_theme_font_size_override("font_size", 15)
	xp_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.38))
	root.add_child(xp_label)

	var pause_button := Button.new()
	pause_button.text = "PAUSE"
	pause_button.anchor_left = 1.0
	pause_button.anchor_right = 1.0
	pause_button.offset_left = -150
	pause_button.offset_right = -28
	pause_button.offset_top = 194
	pause_button.offset_bottom = 238
	pause_button.pressed.connect(_toggle_pause)
	root.add_child(pause_button)

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

	vehicle_select_button = Button.new()
	vehicle_select_button.text = "VEHICLE: BLUE SEDAN"
	vehicle_select_button.anchor_left = 1.0
	vehicle_select_button.anchor_right = 1.0
	vehicle_select_button.offset_left = -230
	vehicle_select_button.offset_right = -28
	vehicle_select_button.offset_top = 136
	vehicle_select_button.offset_bottom = 184
	vehicle_select_button.pressed.connect(_cycle_vehicle)
	root.add_child(vehicle_select_button)

	_add_touch_button(root, "↑", Vector2(112, -150), "move_forward")
	_add_touch_button(root, "↓", Vector2(112, -58), "move_back")
	_add_touch_button(root, "←", Vector2(18, -104), "move_left")
	_add_touch_button(root, "→", Vector2(206, -104), "move_right")
	jump_button = _add_action_button(root, "JUMP", Vector2(-280, -100), Vector2(112, 68), func() -> void:
		if is_instance_valid(player) and not is_driving:
			player.jump()
	)
	brake_button = _add_action_button(root, "BRAKE", Vector2(-150, -100), Vector2(112, 68), func() -> void: Input.action_press("vehicle_brake"), func() -> void: Input.action_release("vehicle_brake"))
	brake_button.visible = false

func _build_adventure_mission() -> void:
	# Keep a completed one-time starter mission completed after loading a save.
	if mission_completed:
		mission_stage = 2
		return
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
		total_xp += 100
		_save_progress()
		records_label.text = _records_text()
		xp_label.text = "XP  •  %d" % total_xp
		mission_two_label.text = "MISSION 02  •  Ready at the park plaza"
		status_label.text = "Delivery completed • You earned 100 XP. Mission 02 is now unlocked."

func _cycle_vehicle() -> void:
	if is_driving:
		status_label.text = "Exit the vehicle before changing cars."
		return
	if player.global_position.distance_to(vehicle.global_position) > 9.0:
		status_label.text = "Walk near your parked car before switching vehicles."
		return
	var parked_transform := vehicle.global_transform
	var previous_vehicle := vehicle
	remove_child(previous_vehicle)
	previous_vehicle.queue_free()
	vehicle_variant = 1 - vehicle_variant
	var next_scene := SPORT_CAR_SCENE if vehicle_variant == 1 else CAR_SCENE
	vehicle = next_scene.instantiate() as CharacterBody3D
	add_child(vehicle)
	vehicle.global_transform = parked_transform
	vehicle.set_physics_process(false)
	vehicle_select_button.text = "VEHICLE: RED SPORT" if vehicle_variant == 1 else "VEHICLE: BLUE SEDAN"
	status_label.text = "Vehicle changed • Your parked position has been kept."

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
		if is_instance_valid(menu_camera):
			menu_camera.current = false
		vehicle.get_node("CameraPivot/Camera3D").current = true
		vehicle.set_physics_process(true)
		if is_instance_valid(jump_button):
			jump_button.visible = false
		if is_instance_valid(brake_button):
			brake_button.visible = true
		drive_button.text = "EXIT CAR"
		status_label.text = "Driving mode • Use the arrows to steer and accelerate."
	else:
		is_driving = false
		player.global_position = vehicle.global_position + vehicle.global_basis.x * 2.5
		player.rotation.y = vehicle.rotation.y
		player.visible = true
		player.get_node("CollisionShape3D").set_deferred("disabled", false)
		player.get_node("CameraPivot/Camera3D").current = true
		if is_instance_valid(menu_camera):
			menu_camera.current = false
		vehicle.get_node("CameraPivot/Camera3D").current = false
		vehicle.set_physics_process(false)
		vehicle.velocity = Vector3.ZERO
		if is_instance_valid(jump_button):
			jump_button.visible = true
		if is_instance_valid(brake_button):
			brake_button.visible = false
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
		Vector3(0.0, 0.0, -37.0),
		Vector3(0.0, 0.0, -8.0),
		Vector3(18.0, 0.0, -8.0),
		Vector3(34.0, 0.0, -8.0),
		Vector3(34.0, 0.0, 20.0),
		Vector3(34.0, 0.0, 48.0),
		Vector3(0.0, 0.0, 48.0),
		Vector3(-34.0, 0.0, 48.0),
		Vector3(-34.0, 0.0, 20.0)
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
	elif title == "Mission 02":
		button.pressed.connect(_start_second_mission)
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

func _add_action_button(parent: Control, label_text: String, offset: Vector2, button_size: Vector2, action: Callable, release_action: Callable = Callable()) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = button_size
	button.anchor_left = 1.0
	button.anchor_top = 1.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = offset.x
	button.offset_top = offset.y
	button.offset_right = offset.x + button_size.x
	button.offset_bottom = offset.y + button_size.y
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(action)
	if release_action.is_valid():
		button.button_down.connect(action)
		button.button_up.connect(release_action)
	parent.add_child(button)
	return button

func _start_second_mission() -> void:
	if not mission_completed:
		status_label.text = "Complete Mission 01 to unlock the park supply mission."
		return
	if mission_two_completed:
		status_label.text = "Park supply mission completed • Your reward is saved."
		return
	if mission_two_active:
		status_label.text = "Mission 02 is active • Collect the glowing supply caches in order."
		return
	if is_driving:
		status_label.text = "Exit the vehicle before starting the park supply mission."
		return
	mission_two_active = true
	mission_two_index = 0
	var targets: Array[Vector3] = [Vector3(-18.0, 0.0, 62.0), Vector3(0.0, 0.0, 82.0), Vector3(18.0, 0.0, 62.0)]
	for index in range(targets.size()):
		var area := _create_mission_area("ParkSupplyCache_%02d" % index, targets[index], Color(0.35, 0.85, 1.0))
		for connection in area.body_entered.get_connections():
			area.body_entered.disconnect(connection.callable)
		area.body_entered.connect(_on_second_mission_area_entered.bind(index))
		mission_two_areas.append(area)
	mission_two_label.text = "MISSION 02  •  0/3 CACHES"
	status_label.text = "Park supply mission started • Explore the plaza and collect all three caches."

func _on_second_mission_area_entered(body: Node3D, index: int) -> void:
	if body != player or not mission_two_active or index != mission_two_index:
		return
	if index < mission_two_areas.size() and is_instance_valid(mission_two_areas[index]):
		mission_two_areas[index].queue_free()
	mission_two_index += 1
	if mission_two_index >= 3:
		mission_two_active = false
		mission_two_completed = true
		total_xp += 150
		mission_two_label.text = "MISSION 02  •  COMPLETE"
		status_label.text = "Park supply mission complete • You earned 150 XP."
		_save_progress()
		records_label.text = _records_text()
		xp_label.text = "XP  •  %d" % total_xp
	else:
		mission_two_label.text = "MISSION 02  •  %d/3 CACHES" % mission_two_index
		status_label.text = "Supply cache secured • Find the next glowing marker."

func _toggle_pause() -> void:
	if pause_panel != null and is_instance_valid(pause_panel):
		_close_pause_menu()
		return
	get_tree().paused = true
	pause_panel = _create_fullscreen_menu_overlay()
	var panel := _create_menu_panel(pause_panel, Vector2(500, 470))
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 12)
	panel.add_child(menu)
	_add_menu_heading(menu, "GAME PAUSED", "Your progress is stored locally on this device.")
	_add_menu_button(menu, "RESUME GAME", _close_pause_menu)
	_add_menu_button(menu, "SAVE PROGRESS", func() -> void:
		_save_progress()
		status_label.text = "Progress saved on this device."
	)
	_add_menu_button(menu, "MAIN MENU", _show_home_menu)
	_add_menu_button(menu, "RESTART SESSION", _restart_session)
	_add_menu_footer(menu, "One Man Squad  •  Offline mode")
	resume_menu_focus(menu)

func _close_pause_menu() -> void:
	if pause_panel != null and is_instance_valid(pause_panel):
		pause_panel.queue_free()
	pause_panel = null
	get_tree().paused = false

func _restart_session() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _show_home_menu() -> void:
	if hud_root != null:
		hud_root.visible = false
	if pause_panel != null and is_instance_valid(pause_panel):
		pause_panel.queue_free()
	pause_panel = null
	get_tree().paused = true
	if is_instance_valid(menu_camera):
		menu_camera.current = true
	_build_home_screen("home")

func _show_settings_screen() -> void:
	_build_home_screen("settings")

func _show_about_screen() -> void:
	_build_home_screen("about")

func _show_garage_screen() -> void:
	_build_home_screen("garage")

func _show_modes_screen() -> void:
	_build_home_screen("modes")

func _build_home_screen(screen: String) -> void:
	if home_overlay != null and is_instance_valid(home_overlay):
		home_overlay.queue_free()
	home_overlay = _create_fullscreen_menu_overlay()
	var safe_area := MarginContainer.new()
	safe_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_area.add_theme_constant_override("margin_left", 24)
	safe_area.add_theme_constant_override("margin_right", 24)
	safe_area.add_theme_constant_override("margin_top", 20)
	safe_area.add_theme_constant_override("margin_bottom", 20)
	home_overlay.add_child(safe_area)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	safe_area.add_child(center)
	var panel := _create_menu_panel(home_overlay, Vector2(500, 0))
	# Reparent the panel into the responsive center container.
	var old_center := panel.get_parent()
	old_center.remove_child(panel)
	old_center.queue_free()
	center.add_child(panel)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 10)
	panel.add_child(menu)
	if screen == "home":
		_add_menu_heading(menu, "ONE MAN SQUAD", "OPEN WORLD  •  RACING  •  SURVIVAL")
		var welcome := Label.new()
		welcome.text = "Your next adventure starts here."
		welcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		welcome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		menu.add_child(welcome)
		_add_menu_button(menu, "PLAY / CONTINUE", _enter_game)
		_add_menu_button(menu, "GARAGE", _show_garage_screen)
		_add_menu_button(menu, "GAME MODES", _show_modes_screen)
		_add_menu_button(menu, "SETTINGS", _show_settings_screen)
		_add_menu_button(menu, "ABOUT", _show_about_screen)
		_add_menu_footer(menu, "Single-player foundation • Online features are planned")
	elif screen == "garage":
		_add_menu_heading(menu, "GARAGE", "Choose your available vehicle.")
		_add_menu_button(menu, "BLUE CITY SEDAN", func() -> void: _select_garage_vehicle(0))
		_add_menu_button(menu, "RED SPORT COUPE", func() -> void: _select_garage_vehicle(1))
		_add_menu_button(menu, "BACK TO MAIN MENU", _show_home_menu)
		_add_menu_footer(menu, "Vehicle customisation and upgrade workshop are planned for a later stage.")
	elif screen == "modes":
		_add_menu_heading(menu, "GAME MODES", "Choose an available experience.")
		_add_menu_button(menu, "OPEN WORLD — AVAILABLE", _enter_game)
		_add_menu_button(menu, "TIME TRIAL — AVAILABLE", func() -> void:
			_enter_game()
			status_label.text = "Enter a vehicle and choose Racing to begin the time trial."
		)
		var survival_note := Label.new()
		survival_note.text = "SURVIVAL ZONE — PLANNED"
		survival_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		survival_note.add_theme_color_override("font_color", Color(1.0, 0.76, 0.4))
		menu.add_child(survival_note)
		var online_note := Label.new()
		online_note.text = "ONLINE MULTIPLAYER — PLANNED"
		online_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		online_note.add_theme_color_override("font_color", Color(1.0, 0.76, 0.4))
		menu.add_child(online_note)
		_add_menu_button(menu, "BACK TO MAIN MENU", _show_home_menu)
	elif screen == "settings":
		_add_menu_heading(menu, "SETTINGS", "Adjust camera response.")
		var sensitivity_label := Label.new()
		sensitivity_label.text = "Camera sensitivity"
		sensitivity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		menu.add_child(sensitivity_label)
		var sensitivity := HSlider.new()
		sensitivity.min_value = 0.002
		sensitivity.max_value = 0.012
		sensitivity.step = 0.001
		sensitivity.value = float(save_config.get_value("settings", "camera_sensitivity", 0.006))
		sensitivity.custom_minimum_size = Vector2(340, 42)
		sensitivity.value_changed.connect(_set_camera_sensitivity)
		menu.add_child(sensitivity)
		_add_menu_button(menu, "BACK TO MAIN MENU", _show_home_menu)
	elif screen == "about":
		_add_menu_heading(menu, "ABOUT ONE MAN SQUAD", "An expanding open-world action and racing project.")
		var about_text := Label.new()
		about_text.text = "This build is the foundation stage. Open-world exploration and time trial are playable prototypes. Survival, online multiplayer, equipment workshop and expanded racing are not implemented yet."
		about_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		about_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		menu.add_child(about_text)
		_add_menu_button(menu, "BACK TO MAIN MENU", _show_home_menu)
	resume_menu_focus(menu)

func _select_garage_vehicle(target_variant: int) -> void:
	if is_driving:
		return
	if target_variant == vehicle_variant:
		_build_home_screen("garage")
		return
	var parked_transform := vehicle.global_transform
	vehicle.queue_free()
	vehicle_variant = target_variant
	var next_scene := SPORT_CAR_SCENE if vehicle_variant == 1 else CAR_SCENE
	vehicle = next_scene.instantiate() as CharacterBody3D
	add_child(vehicle)
	vehicle.global_transform = parked_transform
	vehicle.set_physics_process(false)
	vehicle.set("look_sensitivity", float(save_config.get_value("settings", "camera_sensitivity", 0.006)))
	_build_home_screen("garage")

func _enter_game() -> void:
	if home_overlay != null and is_instance_valid(home_overlay):
		home_overlay.queue_free()
	home_overlay = null
	if hud_root != null:
		hud_root.visible = true
	get_tree().paused = false
	if is_instance_valid(menu_camera):
		menu_camera.current = false
	if is_instance_valid(vehicle) and is_driving:
		vehicle.get_node("CameraPivot/Camera3D").current = true
	elif is_instance_valid(player):
		player.get_node("CameraPivot/Camera3D").current = true
	if is_instance_valid(status_label):
		status_label.text = "Welcome to the city • Explore, complete missions, or start a race."

func _set_camera_sensitivity(value: float) -> void:
	if is_instance_valid(player):
		player.set("look_sensitivity", value)
	if is_instance_valid(vehicle):
		vehicle.set("look_sensitivity", value)
	save_config.set_value("settings", "camera_sensitivity", value)
	save_config.save("user://progress.cfg")

func _create_fullscreen_menu_overlay() -> Control:
	var overlay := Control.new()
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 100
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.045, 0.94)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	ui_canvas.add_child(overlay)
	return overlay

func _create_menu_panel(parent: Control, minimum_size: Vector2) -> PanelContainer:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = minimum_size
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.085, 0.13, 0.98)
	style.border_color = Color(0.22, 0.62, 0.82, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(22)
	style.content_margin_left = 34
	style.content_margin_right = 34
	style.content_margin_top = 28
	style.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)
	return panel

func _add_menu_heading(parent: VBoxContainer, heading_text: String, subtitle_text: String) -> void:
	var heading := Label.new()
	heading.text = heading_text
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 30)
	heading.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0))
	parent.add_child(heading)
	var subtitle := Label.new()
	subtitle.text = subtitle_text
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color(0.45, 0.82, 0.96))
	parent.add_child(subtitle)

func _add_menu_button(parent: VBoxContainer, label_text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(380, 62)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 19)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _add_menu_footer(parent: VBoxContainer, footer_text: String) -> void:
	var footer := Label.new()
	footer.text = footer_text
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.add_theme_font_size_override("font_size", 11)
	footer.add_theme_color_override("font_color", Color(0.62, 0.69, 0.76))
	parent.add_child(footer)

func resume_menu_focus(parent: VBoxContainer) -> void:
	for child in parent.get_children():
		if child is Button:
			child.grab_focus()
			return

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
	mission_two_completed = bool(save_config.get_value("progress", "mission_two_completed", false))
	total_xp = int(save_config.get_value("progress", "total_xp", 0))
	best_time_trial = float(save_config.get_value("records", "best_time_trial", 0.0))
	completed_competition_rounds = int(save_config.get_value("records", "competition_rounds", 0))

func _save_progress() -> void:
	save_config.set_value("progress", "mission_completed", mission_completed)
	save_config.set_value("progress", "mission_two_completed", mission_two_completed)
	save_config.set_value("progress", "total_xp", total_xp)
	save_config.set_value("records", "best_time_trial", best_time_trial)
	save_config.set_value("records", "competition_rounds", completed_competition_rounds)
	var error := save_config.save("user://progress.cfg")
	if error != OK:
		push_warning("Could not save local progress. Error code: %s" % error)

func _records_text() -> String:
	var mission_text := "Delivery: COMPLETE" if mission_completed else "Delivery: Not completed"
	var time_text := "Best time: --" if best_time_trial <= 0.0 else "Best time: %05.2f s" % best_time_trial
	return "LOCAL PROGRESS  •  %s  •  %s  •  Competition rounds: %d  •  XP: %d" % [mission_text, time_text, completed_competition_rounds, total_xp]
