extends Node3D
## First playable foundation: compact test district, third-person player,
## touch controls, and entry points for the three planned game activities.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")

var player: CharacterBody3D
var status_label: Label
var lobby_panel: PanelContainer

func _ready() -> void:
	_build_environment()
	_build_test_district()
	_spawn_player()
	_build_interface()

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
		var static_body := StaticBody3D.new()
		body = static_body
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
	# Flat ground and a simple road layout make a small navigable test space.
	_add_box(self, "Ground", Vector3(0, -0.25, 0), Vector3(90, 0.5, 90), Color(0.27, 0.39, 0.31), true)
	_add_box(self, "MainRoad", Vector3(0, 0.015, 0), Vector3(9, 0.04, 78), Color(0.12, 0.13, 0.15))
	_add_box(self, "CrossRoad", Vector3(0, 0.025, -8), Vector3(78, 0.04, 8), Color(0.12, 0.13, 0.15))

	var building_colors: Array[Color] = [
		Color(0.68, 0.66, 0.61),
		Color(0.53, 0.61, 0.66),
		Color(0.73, 0.70, 0.62),
		Color(0.48, 0.53, 0.57)
	]
	var building_positions: Array[Vector3] = [
		Vector3(-15, 3, -18), Vector3(15, 4, -19),
		Vector3(-18, 2.5, 7), Vector3(18, 3.5, 8),
		Vector3(-15, 3, 24), Vector3(15, 2.5, 25),
		Vector3(-29, 4, -5), Vector3(29, 3, -5)
	]
	for index in range(building_positions.size()):
		var height := building_positions[index].y * 2.0
		_add_box(
			self,
			"DistrictBuilding_%02d" % index,
			building_positions[index],
			Vector3(9, height, 9),
			building_colors[index % building_colors.size()],
			true
		)

func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate() as CharacterBody3D
	player.position = Vector3(0, 0.1, 8)
	add_child(player)

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

	_add_activity_button(activity_box, "Adventure", "Explore the starter district and test movement.")
	_add_activity_button(activity_box, "Competition", "Challenge-zone foundation: objective-based AI rounds will be added here.")
	_add_activity_button(activity_box, "Racing", "Race-mode foundation: vehicle handling and tracks will be added here.")

	status_label = Label.new()
	status_label.text = "Prototype build • Offline foundation"
	status_label.position = Vector2(28, 205)
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(status_label)

	_add_touch_button(root, "↑", Vector2(112, -150), "move_forward")
	_add_touch_button(root, "↓", Vector2(112, -58), "move_back")
	_add_touch_button(root, "←", Vector2(18, -104), "move_left")
	_add_touch_button(root, "→", Vector2(206, -104), "move_right")

func _add_activity_button(parent: VBoxContainer, title: String, description: String) -> void:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(220, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
