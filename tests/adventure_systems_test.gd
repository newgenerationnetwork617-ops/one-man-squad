extends SceneTree
## Checks offline NPC dialogue, mission objective flow and waypoint guidance.

const NPCS = preload("res://scripts/adventure/npc_registry.gd")
const MISSIONS = preload("res://scripts/adventure/mission_manager.gd")
const NAVIGATION = preload("res://scripts/adventure/navigation_manager.gd")
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("ADVENTURE SYSTEM TEST FAILED: " + message)

func _run() -> void:
	var npcs = NPCS.new()
	_check(npcs.register_npc("mechanic_01", "Tunde", "mechanic", ["Welcome to the garage.", "I have a delivery job."]), "NPC should register.")
	_check(not npcs.register_npc("mechanic_01", "Duplicate", "mechanic", []), "Duplicate NPC IDs should be rejected.")
	_check(npcs.interact("mechanic_01"), "Registered NPC should start dialogue.")
	_check(npcs.get_npc("mechanic_01").interactions == 1, "NPC interaction count should increment.")
	npcs.close_dialogue()
	_check(npcs.active_npc_id.is_empty(), "Closing dialogue should clear the active NPC.")

	var missions = MISSIONS.new()
	var mission := {"id":"parts_delivery","title":"Workshop Delivery","xp_reward":150,"gold_reward":40,"objectives":[{"type":"interact","target":"mechanic_01","count":1},{"type":"visit","target":"farmhouse","count":1}]}
	_check(missions.register_mission(mission), "Valid mission should register.")
	_check(missions.start_mission("parts_delivery"), "Available mission should start.")
	_check(not missions.advance_objective("visit", "farmhouse"), "Out-of-order objective should not advance.")
	_check(missions.advance_objective("interact", "mechanic_01"), "First objective should advance.")
	_check(missions.advance_objective("visit", "farmhouse"), "Second objective should advance.")
	_check(missions.missions.parts_delivery.status == "completed", "Mission should complete after all objectives.")

	var nav = NAVIGATION.new()
	_check(nav.add_marker("home", "Home", "home", Vector3.ZERO), "Home marker should register.")
	_check(nav.add_marker("plaza", "Town Plaza", "activity", Vector3(30, 0, 40)), "Plaza marker should register.")
	_check(nav.discover("plaza"), "Marker should be discoverable.")
	_check(nav.toggle_favourite("plaza"), "Marker should be favouritable.")
	_check(nav.set_destination("plaza"), "Known marker should become destination.")
	var guidance := nav.guidance_from(Vector3.ZERO)
	_check(is_equal_approx(float(guidance.distance), 50.0), "Waypoint distance should be calculated.")
	_check(nav.visible_markers().size() == 1, "Undiscovered markers should stay hidden by default.")
	if failures.is_empty():
		print("ADVENTURE SYSTEM TESTS PASSED.")
		quit(0)
	else:
		push_error("ADVENTURE SYSTEM TESTS FAILED: %d check(s)." % failures.size())
		quit(1)
