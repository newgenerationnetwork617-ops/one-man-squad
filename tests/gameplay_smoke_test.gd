extends SceneTree
## Headless gameplay-state checks for the first playable systems.
## This test preserves and restores any existing local player save.

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

var failures: Array[String] = []
var original_save := PackedByteArray()
var had_original_save := false
var save_path := "user://progress.cfg"

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("GAMEPLAY TEST FAILED: " + message)

func _run() -> void:
	had_original_save = FileAccess.file_exists(save_path)
	if had_original_save:
		var source := FileAccess.open(save_path, FileAccess.READ)
		if source != null:
			original_save = source.get_buffer(source.get_length())
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))

	var game := MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	_check(game.get("player") is CharacterBody3D, "The player should spawn.")
	_check(game.get("vehicle") is CharacterBody3D, "The starter vehicle should spawn.")
	_check(game.get("player").get_node_or_null("Hair") != null and game.get("player").get_node_or_null("LeftEye") != null, "The upgraded player should include face and hair details.")
	_check(game.get("vehicle").get_node_or_null("HeadlightLeft") != null and game.get("vehicle").get_node_or_null("FrontBumper") != null, "The upgraded vehicle should include front-end details.")
	_check(game.get("vehicle").get("wheel_nodes").size() == 4, "The vehicle controller should register all four animated wheels.")
	_check(game.get_child_count() > 40, "The starter district should include additional streetscape details.")
	_check(game.get("player").get_node_or_null("Head") != null and game.get("player").get_node_or_null("Torso") != null, "The player should use a humanoid blockout rather than a capsule-only placeholder.")
	game.get("player").global_position.y = -5.0
	game.call("_recover_if_out_of_bounds")
	_check(game.get("player").global_position.y > 0.0, "A fallen player should be returned to the safe spawn point.")
	game.get("vehicle").global_position.y = -5.0
	game.call("_recover_if_out_of_bounds")
	_check(game.get("vehicle").global_position.y > 0.0, "A fallen vehicle should be returned to the safe spawn point.")
	_check(game.get("mission_stage") == 0, "A new save should begin at the first mission step.")

	var player: Node3D = game.get("player")
	var vehicle: Node3D = game.get("vehicle")
	var pickup: Area3D = game.get("pickup_area")
	var delivery: Area3D = game.get("delivery_area")
	game.call("_on_mission_area_entered", player, pickup)
	_check(game.get("mission_stage") == 1, "Collecting the supply should advance the mission.")
	game.call("_on_mission_area_entered", player, delivery)
	_check(game.get("mission_completed") == true, "Reaching the destination should complete the mission.")

	game.set("is_driving", true)
	game.call("_start_time_trial")
	_check(game.get("race_active") == true, "The time trial should start while driving.")
	game.set("race_elapsed", 12.34)
	for checkpoint_index in range(4):
		game.call("_on_race_checkpoint_entered", vehicle, checkpoint_index)
	_check(game.get("race_active") == false, "Passing all four checkpoints should finish the time trial.")
	_check(game.get("best_time_trial") > 0.0, "The best time should be recorded.")

	game.set("is_driving", false)
	game.call("_start_competition_round")
	_check(game.get("competition_active") == true, "The timed objective round should start on foot.")
	for objective_index in range(3):
		game.call("_on_competition_objective_entered", player, objective_index)
	_check(game.get("competition_active") == false, "Collecting all three objectives should finish the round.")
	_check(game.get("completed_competition_rounds") == 1, "The completed round should increment the saved record.")

	var saved := ConfigFile.new()
	_check(saved.load(save_path) == OK, "Progress should be written to the local save file.")
	_check(saved.get_value("progress", "mission_completed", false) == true, "The mission completion flag should be saved.")
	_check(float(saved.get_value("records", "best_time_trial", 0.0)) > 0.0, "The best time should be saved.")
	_check(int(saved.get_value("records", "competition_rounds", 0)) == 1, "The completed round count should be saved.")

	game.queue_free()
	await process_frame

	var reloaded_game := MAIN_SCENE.instantiate()
	root.add_child(reloaded_game)
	await process_frame
	_check(reloaded_game.get("mission_stage") == 2, "A completed mission should remain completed after reload.")
	_check(reloaded_game.get("pickup_area") == null, "A completed mission should not respawn its pickup marker.")
	_check(reloaded_game.get("delivery_area") == null, "A completed mission should not respawn its destination marker.")
	_check(reloaded_game.get("mission_label").text == "MISSION 01  •  COMPLETE", "The HUD should show the completed mission after reload.")
	_check(reloaded_game.get("completed_competition_rounds") == 1, "The competition record should load after reload.")

	reloaded_game.queue_free()
	await process_frame
	_restore_original_save()

	if failures.is_empty():
		print("GAMEPLAY TESTS PASSED: mission, racing, competition, and local save/load.")
		quit(0)
	else:
		push_error("GAMEPLAY TESTS FAILED: %d check(s)." % failures.size())
		quit(1)

func _restore_original_save() -> void:
	if had_original_save:
		var destination := FileAccess.open(save_path, FileAccess.WRITE)
		if destination != null:
			destination.store_buffer(original_save)
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
