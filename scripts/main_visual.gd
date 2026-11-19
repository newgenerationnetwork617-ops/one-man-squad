extends "res://scripts/main_responsive.gd"
## Adds a cohesive, lightweight architectural detail pass to the greybox district.
## All props are decorative meshes; the original collision and mission layout is unchanged.

const FACADE_DATA: Array[Dictionary] = [
	{"position": Vector3(-15, 3, -18), "height": 6.0, "name": "NORTH HOTEL", "accent": Color(0.12, 0.42, 0.55)},
	{"position": Vector3(15, 4, -19), "height": 8.0, "name": "CITY MARKET", "accent": Color(0.72, 0.34, 0.12)},
	{"position": Vector3(-18, 2.5, 7), "height": 5.0, "name": "CAFE", "accent": Color(0.45, 0.28, 0.16)},
	{"position": Vector3(18, 3.5, 8), "height": 7.0, "name": "AUTO WORKS", "accent": Color(0.16, 0.34, 0.52)},
	{"position": Vector3(-15, 3, 24), "height": 6.0, "name": "RESIDENCE", "accent": Color(0.34, 0.42, 0.3)},
	{"position": Vector3(15, 2.5, 25), "height": 5.0, "name": "DINER", "accent": Color(0.62, 0.2, 0.16)},
	{"position": Vector3(-29, 4, -5), "height": 8.0, "name": "OFFICES", "accent": Color(0.22, 0.36, 0.48)},
	{"position": Vector3(29, 3, -5), "height": 6.0, "name": "STUDIO", "accent": Color(0.48, 0.32, 0.2)}
]

func _build_test_district() -> void:
	super._build_test_district()
	_add_architectural_details()
	_add_road_markings()

func _build_park_plaza() -> void:
	super._build_park_plaza()
	_add_park_landmark_details()

func _add_road_markings() -> void:
	var stripe_color := Color(0.9, 0.91, 0.86)
	for index in range(12):
		var z_position := -14.0 + float(index) * 0.95
		_add_box(self, "CrosswalkStripeMain", Vector3(0.0, 0.078, z_position), Vector3(8.6, 0.025, 0.48), stripe_color)
		var x_position := -5.2 + float(index) * 0.95
		_add_box(self, "CrosswalkStripeEastWest", Vector3(x_position, 0.078, -8.0), Vector3(0.48, 0.025, 8.6), stripe_color)
	_add_box(self, "IntersectionStopLine", Vector3(0.0, 0.082, -15.0), Vector3(8.8, 0.03, 0.16), Color(0.96, 0.78, 0.3))
	_add_box(self, "IntersectionStopLine", Vector3(5.0, 0.082, -8.0), Vector3(0.16, 0.03, 8.8), Color(0.96, 0.78, 0.3))
	for side in [-1.0, 1.0]:
		for bay in range(3):
			var x_position: float = side * (12.0 + float(bay) * 3.2)
			_add_box(self, "ParkingBayLine", Vector3(x_position, 0.07, -8.0), Vector3(0.1, 0.025, 5.4), Color(0.78, 0.82, 0.8))

func _add_park_landmark_details() -> void:
	var fountain_ring := MeshInstance3D.new()
	fountain_ring.name = "FountainRim"
	var rim_mesh := TorusMesh.new()
	rim_mesh.inner_radius = 2.0
	rim_mesh.outer_radius = 2.22
	rim_mesh.rings = 12
	rim_mesh.ring_segments = 32
	fountain_ring.mesh = rim_mesh
	fountain_ring.material_override = _material(Color(0.68, 0.72, 0.72))
	fountain_ring.position = Vector3(0.0, 0.72, 72.0)
	add_child(fountain_ring)

	for index in range(4):
		var angle := TAU * float(index) / 4.0
		var jet := MeshInstance3D.new()
		jet.name = "FountainJet"
		var jet_mesh := CylinderMesh.new()
		jet_mesh.top_radius = 0.07
		jet_mesh.bottom_radius = 0.11
		jet_mesh.height = 1.15
		jet.mesh = jet_mesh
		jet.material_override = _material(Color(0.24, 0.66, 0.82))
		jet.position = Vector3(cos(angle) * 1.05, 1.18, 72.0 + sin(angle) * 1.05)
		add_child(jet)

	_add_box(self, "ParkPergolaBeamFront", Vector3(0.0, 3.2, 85.0), Vector3(12.0, 0.22, 0.25), Color(0.28, 0.22, 0.16))
	_add_box(self, "ParkPergolaBeamRear", Vector3(0.0, 3.2, 89.0), Vector3(12.0, 0.22, 0.25), Color(0.28, 0.22, 0.16))
	for x_position in [-5.5, -2.0, 2.0, 5.5]:
		_add_box(self, "ParkPergolaPost", Vector3(x_position, 1.65, 85.0), Vector3(0.22, 3.3, 0.22), Color(0.32, 0.25, 0.18))
		_add_box(self, "ParkPergolaPost", Vector3(x_position, 1.65, 89.0), Vector3(0.22, 3.3, 0.22), Color(0.32, 0.25, 0.18))
	for slat in range(9):
		_add_box(self, "ParkPergolaSlat", Vector3(-5.0 + float(slat) * 1.25, 3.3, 87.0), Vector3(0.12, 0.12, 4.2), Color(0.4, 0.31, 0.22))

	for x_position in [-8.0, 8.0]:
		for z_position in [65.0, 79.0]:
			var shrub := MeshInstance3D.new()
			shrub.name = "ParkShrub"
			var shrub_mesh := SphereMesh.new()
			shrub_mesh.radius = 0.85
			shrub_mesh.height = 1.15
			shrub.mesh = shrub_mesh
			shrub.material_override = _material(Color(0.16, 0.39, 0.2))
			shrub.position = Vector3(x_position, 0.72, z_position)
			add_child(shrub)

	for x_position in [-3.0, 3.0]:
		_add_box(self, "BenchBackrest", Vector3(x_position * 4.0, 1.15, 72.0), Vector3(2.8, 0.85, 0.16), Color(0.42, 0.27, 0.16))
		for z_offset in [-2.5, 2.5]:
			var bollard := MeshInstance3D.new()
			bollard.name = "PathBollard"
			var bollard_mesh := CylinderMesh.new()
			bollard_mesh.top_radius = 0.09
			bollard_mesh.bottom_radius = 0.13
			bollard_mesh.height = 0.72
			bollard.mesh = bollard_mesh
			bollard.material_override = _material(Color(0.2, 0.24, 0.25))
			bollard.position = Vector3(x_position * 2.5, 0.36, 72.0 + z_offset)
			add_child(bollard)

func _add_architectural_details() -> void:
	for item in FACADE_DATA:
		var origin: Vector3 = item["position"]
		var height: float = item["height"]
		var accent: Color = item["accent"]
		var front_z := origin.z - 4.68
		var entrance := MeshInstance3D.new()
		entrance.name = "FacadeEntranceDoor"
		var door_mesh := BoxMesh.new()
		door_mesh.size = Vector3(1.35, 2.25, 0.12)
		entrance.mesh = door_mesh
		entrance.material_override = _material(Color(0.075, 0.11, 0.14))
		entrance.position = Vector3(origin.x, 1.14, front_z)
		add_child(entrance)

		var door_glass := MeshInstance3D.new()
		door_glass.name = "EntranceGlass"
		var glass_mesh := BoxMesh.new()
		glass_mesh.size = Vector3(0.82, 1.52, 0.035)
		door_glass.mesh = glass_mesh
		door_glass.material_override = _material(Color(0.16, 0.34, 0.42))
		door_glass.position = Vector3(origin.x, 1.3, front_z - 0.08)
		add_child(door_glass)

		_add_box(self, "EntranceCanopy", Vector3(origin.x, 2.42, front_z - 0.28), Vector3(3.2, 0.16, 0.82), accent)
		_add_box(self, "EntranceCanopySupport", Vector3(origin.x - 1.35, 2.1, front_z - 0.55), Vector3(0.09, 0.65, 0.09), Color(0.18, 0.2, 0.22))
		_add_box(self, "EntranceCanopySupport", Vector3(origin.x + 1.35, 2.1, front_z - 0.55), Vector3(0.09, 0.65, 0.09), Color(0.18, 0.2, 0.22))

		_add_box(self, "FacadeSignPanel", Vector3(origin.x, 2.95, front_z - 0.07), Vector3(5.8, 0.58, 0.12), accent)
		var sign := Label3D.new()
		sign.name = "BuildingSign"
		sign.text = str(item["name"])
		sign.font_size = 32
		sign.pixel_size = 0.006
		sign.modulate = Color(0.96, 0.96, 0.9)
		sign.outline_size = 5
		sign.position = Vector3(origin.x, 2.88, front_z - 0.16)
		sign.rotation.y = PI
		add_child(sign)

		for floor_y in range(1, int(height / 2.5)):
			for balcony_x in [-3.25, 3.25]:
				_add_box(self, "BalconySlab", Vector3(origin.x + balcony_x, float(floor_y) * 2.5 + 0.5, front_z - 0.32), Vector3(1.7, 0.12, 0.72), Color(0.38, 0.42, 0.43))
				_add_box(self, "BalconyRail", Vector3(origin.x + balcony_x, float(floor_y) * 2.5 + 0.9, front_z - 0.62), Vector3(1.7, 0.58, 0.07), Color(0.17, 0.2, 0.22))
		_add_box(self, "RooftopEquipment", Vector3(origin.x + 2.7, height + 0.55, origin.z + 1.8), Vector3(1.7, 0.9, 1.5), Color(0.32, 0.36, 0.38))
		_add_box(self, "RooftopEquipmentTop", Vector3(origin.x + 2.7, height + 1.03, origin.z + 1.8), Vector3(1.82, 0.08, 1.62), Color(0.18, 0.21, 0.23))

		_add_box(self, "StreetPlanter", Vector3(origin.x - 3.0, 0.38, front_z - 1.0), Vector3(1.35, 0.72, 0.72), Color(0.36, 0.24, 0.16))
		_add_box(self, "StreetPlanterSoil", Vector3(origin.x - 3.0, 0.76, front_z - 1.0), Vector3(1.2, 0.08, 0.58), Color(0.18, 0.13, 0.09))
		_add_box(self, "StorefrontDisplay", Vector3(origin.x + 3.0, 1.2, front_z - 0.03), Vector3(1.35, 1.8, 0.1), Color(0.12, 0.28, 0.34))

