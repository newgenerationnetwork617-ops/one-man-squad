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

func _count_direct_children_with_prefix(parent: Node, prefix: String) -> int:
	var count := 0
	for child in parent.get_children():
		if String(child.name).begins_with(prefix):
			count += 1
	return count

func _run() -> void:
	var game := MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	var entrance_count := _count_direct_children_with_prefix(game, "FacadeEntranceDoor")
	if not _expect(entrance_count == 8, "Expected 8 facade entrance meshes; found %d." % entrance_count):
		return
	var sign_count := _count_direct_children_with_prefix(game, "BuildingSign")
	if not _expect(sign_count == 8, "Expected 8 building signs; found %d." % sign_count):
		return
	var rooftop_count := _count_direct_children_with_prefix(game, "RooftopEquipment_")
	if not _expect(rooftop_count == 8, "Expected 8 rooftop utility props; found %d." % rooftop_count):
		return
	var crossing_count := _count_direct_children_with_prefix(game, "CrosswalkStripeMain")
	if not _expect(crossing_count == 12, "Expected 12 main-road crossing stripes; found %d." % crossing_count):
		return
	if not _expect(game.find_child("FountainRim", true, false) != null, "The park fountain should have a defined rim."):
		return
	var pergola_count := _count_direct_children_with_prefix(game, "ParkPergolaSlat")
	if not _expect(pergola_count == 9, "Expected 9 pergola slats; found %d." % pergola_count):
		return
	if not _expect(game.get_node_or_null("Ground") != null, "Original district ground should remain present."):
		return
	if not _expect(game.get_node_or_null("ParkPlazaGround") != null, "Original park plaza should remain present."):
		return
	if not _expect(game.get_node_or_null("CountrysideMainRoad") != null, "Connected countryside road should be present."):
		return
	if not _expect(game.get_node_or_null("CountryFarmhouse") != null, "Countryside farmhouse should be present."):
		return
	if not _expect(game.get_node_or_null("CountryBarn") != null, "Countryside barn should be present."):
		return
	if not _expect(game.get_node_or_null("CountrysidePond") != null, "Countryside pond should be present."):
		return
	if not _expect(_count_direct_children_with_prefix(game, "BoundaryA_") == 2, "Both expanded world boundary walls should be present."):
		return
	if not _expect(game.get("home_overlay") != null, "The responsive home menu should still initialise."):
		return
	game.queue_free()
	await process_frame
	print("ARCHITECTURAL DETAIL TESTS PASSED.")
	quit(0)
