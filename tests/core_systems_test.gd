extends SceneTree
## Offline foundation tests for save slots, progression and world time/weather.

const PROFILE_STORE_SCRIPT = preload("res://scripts/core/profile_store.gd")
const PROGRESSION_SCRIPT = preload("res://scripts/core/progression_manager.gd")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("CORE SYSTEM TEST FAILED: " + message)

func _run() -> void:
	var store = PROFILE_STORE_SCRIPT.new()
	store.delete_slot(1)
	var profile := store.default_profile("Test Pilot")
	_check(store.save_slot(1, profile) == OK, "A new profile should save to slot one.")
	var loaded := store.load_slot(1)
	_check(bool(loaded.get("ok", false)), "A saved profile should load.")
	_check(loaded.profile.identity.display_name == "Test Pilot", "The display name should survive a save/load cycle.")
	var slots := store.list_slots()
	_check(slots[0].occupied == true and slots[0].level == 1, "Slot listing should report occupied profile metadata.")
	var revised_profile: Dictionary = profile.duplicate(true)
	revised_profile["identity"]["display_name"] = "Second Pilot"
	_check(store.save_slot(1, revised_profile) == OK, "An updated profile should save and create a recovery copy.")
	var corrupt_file := FileAccess.open("user://profiles/slot_1.cfg", FileAccess.WRITE)
	if corrupt_file != null:
		corrupt_file.store_string("corrupted profile data")
		corrupt_file.close()
	var recovered := store.load_slot(1)
	_check(bool(recovered.get("ok", false)), "A corrupt current profile should recover from its backup.")
	_check(recovered.profile.identity.display_name == "Test Pilot", "Recovery should restore the previous valid profile.")
	_check(store.save_slot(0, profile) == ERR_INVALID_PARAMETER, "Invalid slots should be rejected.")
	var progression = PROGRESSION_SCRIPT.new()
	var rewarded := progression.award(profile, 800, 120, 2)
	_check(rewarded.progress.xp == 800, "XP rewards should accumulate.")
	_check(rewarded.progress.gold == 120 and rewarded.progress.tokens == 2, "Gameplay currency rewards should accumulate.")
	_check(rewarded.progress.level == 4, "Level should derive from XP thresholds.")
	_check(progression.rank_for_xp(800).name == "Challenger", "Rank should reflect earned XP.")
	_check(progression.unlocks_for_xp(800).has("sports_car"), "XP milestones should unlock the sports car.")
	_check(progression.award(profile, -100, -5, -1).progress.xp == 0, "Negative rewards must not reduce or corrupt balances.")
	store.delete_slot(1)

	var world_script := load("res://scripts/world/world_cycle.gd")
	var world: Node = world_script.new()
	root.add_child(world)
	var environment_node := WorldEnvironment.new()
	environment_node.environment = Environment.new()
	var sun := DirectionalLight3D.new()
	root.add_child(environment_node)
	root.add_child(sun)
	world.configure(environment_node, sun)
	world.set_time_of_day(18.0)
	_check(is_equal_approx(world.time_of_day, 18.0), "World time should accept explicit hour settings.")
	_check(world.set_weather("fog"), "Fog weather should be supported.")
	_check(environment_node.environment.fog_enabled, "Fog weather should enable world fog.")
	_check(world.weather_name() == "fog", "Weather state should be queryable.")
	_check(not world.set_weather("snow"), "Unsupported weather values should be rejected.")
	world.queue_free()
	environment_node.queue_free()
	sun.queue_free()
	await process_frame
	if failures.is_empty():
		print("CORE SYSTEM TESTS PASSED: profiles, progression, day/night and weather.")
		quit(0)
	else:
		push_error("CORE SYSTEM TESTS FAILED: %d check(s)." % failures.size())
		quit(1)
