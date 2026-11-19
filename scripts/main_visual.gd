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

