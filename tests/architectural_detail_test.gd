extends SceneTree
## Verifies that the architectural pass adds named detail without replacing gameplay geometry.

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game := MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	assert(game.find_children("FacadeEntranceDoor", "MeshInstance3D", true, false).size() >= 8,
		"Each starter-district building should have an entrance detail.")
	assert(game.find_children("BuildingSign", "Label3D", true, false).size() == 8,
		"All eight buildings should receive a named sign.")
	assert(game.find_children("RooftopEquipment", "MeshInstance3D", true, false).size() == 8,
		"All eight buildings should receive rooftop detail.")
	assert(game.find_children("CrosswalkStripeMain", "Node3D", true, false).size() == 12,
		"The main road intersection should include a full pedestrian crossing.")
	assert(game.find_children("FountainRim", "MeshInstance3D", true, false).size() == 1,
		"The park fountain should have a defined rim.")
	assert(game.find_children("ParkPergolaSlat", "Node3D", true, false).size() == 9,
		"The park plaza should include the pergola landmark detail.")
	assert(game.get_node_or_null("Ground") != null, "Original district ground should remain present.")
	assert(game.get_node_or_null("ParkPlazaGround") != null, "Original park plaza should remain present.")
	assert(game.get("home_overlay") != null, "The responsive home menu should still initialise.")
	game.queue_free()
	await process_frame
	print("ARCHITECTURAL DETAIL TESTS PASSED.")
	quit(0)
