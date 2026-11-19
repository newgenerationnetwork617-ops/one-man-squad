extends SceneTree
## Checks responsive menu behavior on a narrow portrait and short landscape viewport.

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(360, 640)
	var game := MAIN_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	var overlay: Control = game.get("home_overlay")
	assert(overlay != null and is_instance_valid(overlay), "Home menu should exist at startup.")
	var panel := overlay.find_child("ResponsivePanel", true, false) as PanelContainer
	var scroll := overlay.find_child("ContentScroll", true, false) as ScrollContainer
	var menu := overlay.find_child("MenuContent", true, false) as VBoxContainer
	assert(panel != null, "Responsive menu panel should be created.")
	assert(scroll != null, "Menu content should be vertically scrollable on short screens.")
	assert(menu != null, "Menu content should be grouped in a responsive vertical layout.")
	assert(panel.custom_minimum_size.x <= root.size.x, "Menu panel width must not exceed the portrait viewport.")
	assert(is_equal_approx(panel.custom_minimum_size.x, 320.0), "Portrait panel should fit a 360 px viewport with margins.")
	for child in menu.get_children():
		if child is Button:
			assert(child.custom_minimum_size.x == 0.0, "Menu buttons must use available width instead of a fixed mobile-breaking width.")

	root.size = Vector2i(640, 360)
	game.call("_show_garage_screen")
	var landscape_overlay: Control = game.get("home_overlay")
	var landscape_panel := landscape_overlay.find_child("ResponsivePanel", true, false) as PanelContainer
	assert(landscape_panel != null, "Garage should use the responsive panel in landscape.")
	assert(landscape_panel.custom_minimum_size.y <= root.size.y, "Garage panel height must fit a short landscape viewport.")
	assert(landscape_overlay.find_child("ContentScroll", true, false) != null, "Garage should scroll when vertical space is limited.")

	root.size = Vector2i(360, 640)
	game.call("_toggle_pause")
	assert(game.get("pause_panel").find_child("ScrollContainer", true, false) != null, "Pause menu should also scroll on short screens.")
	game.call("_close_pause_menu")
	game.queue_free()
	await process_frame
	print("RESPONSIVE UI TESTS PASSED.")
	quit(0)
