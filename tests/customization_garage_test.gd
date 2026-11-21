extends SceneTree
## Checks the offline character appearance and eight-entry garage catalogue.

const CUSTOMIZER = preload("res://scripts/core/character_customizer.gd")
const CATALOG = preload("res://scripts/core/vehicle_catalog.gd")
const PLAYER_SCENE = preload("res://scenes/player.tscn")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("CUSTOMIZATION/GARAGE TEST FAILED: " + message)

func _run() -> void:
	var player := PLAYER_SCENE.instantiate() as Node3D
	root.add_child(player)
	var appearance := CUSTOMIZER.defaults()
	appearance.skin_tone = "deep_brown"
	appearance.outfit = "burgundy"
	appearance.trousers = "tan"
	appearance.hair_style = "shaved"
	_check(CUSTOMIZER.apply_to_player(player, appearance), "A valid appearance should apply to the player.")
	_check(not player.get_node("Hair").visible, "Shaved hairstyle should hide the hair mesh.")
	_check(not CUSTOMIZER.apply_to_player(player, {"skin_tone":"unknown"}), "Unknown appearance options should be rejected.")
	_check(CATALOG.all_vehicles().size() == 8, "The first-release catalogue should contain eight vehicles.")
	_check(CATALOG.is_unlocked("starter_sedan", 0), "The starter vehicle should be available immediately.")
	_check(not CATALOG.is_unlocked("street_supercar", 0), "The supercar should remain progression-locked initially.")
	_check(CATALOG.is_unlocked("street_supercar", 2400), "The supercar should unlock at its XP threshold.")
	_check(CATALOG.get_vehicle("missing").is_empty(), "Unknown vehicle IDs should return an empty result.")
	player.queue_free()
	await process_frame
	if failures.is_empty():
		print("CUSTOMIZATION/GARAGE TESTS PASSED.")
		quit(0)
	else:
		push_error("CUSTOMIZATION/GARAGE TESTS FAILED: %d check(s)." % failures.size())
		quit(1)
