extends SceneTree
## Checks responsive menu behavior on a narrow portrait and short landscape viewport.

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
	root.size = Vector2i(360, 640)
	await process_frame
	var game := MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	var overlay: Control = game.get("home_overlay")
	if not _expect(overlay != null and is_instance_valid(overlay), "Home menu should exist at startup."):
		return
	var panel := overlay.find_child("ResponsivePanel", true, false) as PanelContainer
	var scroll := overlay.find_child("ContentScroll", true, false) as ScrollContainer
	var menu := overlay.find_child("MenuContent", true, false) as VBoxContainer
	if not _expect(panel != null, "Responsive menu panel should be created."):
		return
	if not _expect(scroll != null, "Menu content should be vertically scrollable on short screens."):
		return
	if not _expect(menu != null, "Menu content should be grouped in a responsive vertical layout."):
		return
	if not _expect(panel.custom_minimum_size.x <= root.size.x, "Menu panel width must not exceed the portrait viewport."):
		return
	if not _expect(is_equal_approx(panel.custom_minimum_size.x, 320.0), "Portrait panel should fit a 360 px viewport with margins."):
		return
	for child in menu.get_children():
		if child is Button and not _expect(child.custom_minimum_size.x == 0.0, "Menu buttons must use available width instead of a fixed mobile-breaking width."):
			return

	root.size = Vector2i(640, 360)
	await process_frame
	game.call("_show_garage_screen")
	await process_frame
	var landscape_overlay: Control = game.get("home_overlay")
	var landscape_panel := landscape_overlay.find_child("ResponsivePanel", true, false) as PanelContainer
	if not _expect(landscape_panel != null, "Garage should use the responsive panel in landscape."):
		return
	if not _expect(landscape_panel.custom_minimum_size.y <= root.size.y, "Garage panel height must fit a short landscape viewport."):
		return
	if not _expect(landscape_overlay.find_child("ContentScroll", true, false) != null, "Garage should scroll when vertical space is limited."):
		return

	root.size = Vector2i(360, 640)
	await process_frame
	game.call("_toggle_pause")
	var pause_overlay: Control = game.get("pause_panel")
	if not _expect(pause_overlay != null and pause_overlay.find_child("ScrollContainer", true, false) != null, "Pause menu should also scroll on short screens."):
		return
	game.call("_close_pause_menu")
	game.queue_free()
	await process_frame
	print("RESPONSIVE UI TESTS PASSED.")
	quit(0)
