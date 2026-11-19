extends SceneTree
## Verifies the architectural pass while preserving gameplay geometry.

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _expect(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false

func _run() -> void:
	var game := MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	if not _expect(game.find_children("FacadeEntranceDoor*", "MeshInstance3D", true, false).size() >= 8,
			"Each starter-district building should have an entrance detail."):
		return
	if not _expect(game.find_children("BuildingSign*", "Label3D", true, false).size() == 8,
			"All eight buildings should receive a named sign."):
		return
	if not _expect(game.find_children("RooftopEquipment*", "Node3D", true, false).size() == 8,
			"All eight buildings should receive rooftop detail."):
		return
	if not _expect(game.find_children("CrosswalkStripeMain*", "Node3D", true, false).size() == 12,
			"The main road intersection should include a full pedestrian crossing."):
		return
	if not _expect(game.find_children("FountainRim", "MeshInstance3D", true, false).size() == 1,
			"The park fountain should have a defined rim."):
		return
	if not _expect(game.find_children("ParkPergolaSlat*", "Node3D", true, false).size() == 9,
			"The park plaza should include the pergola landmark detail."):
		return
	if not _expect(game.get_node_or_null("Ground") != null, "Original district ground should remain present."):
		return
	if not _expect(game.get_node_or_null("ParkPlazaGround") != null, "Original park plaza should remain present."):
		return
	if not _expect(game.get("home_overlay") != null, "The responsive home menu should still initialise."):
		return
	game.queue_free()
	await process_frame
	print("ARCHITECTURAL DETAIL TESTS PASSED.")
	quit(0)
