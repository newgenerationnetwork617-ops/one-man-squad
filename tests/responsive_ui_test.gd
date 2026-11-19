extends SceneTree
## Checks responsive sizing math and the actual menu/garage/pause containers.

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

	var portrait_size: Vector2 = game.call("_responsive_panel_dimensions", Vector2(360.0, 640.0), 620.0)
	if not _expect(is_equal_approx(portrait_size.x, 320.0) and is_equal_approx(portrait_size.y, 600.0),
			"Portrait dimensions should preserve 20 px side and top/bottom margins."):
		return
	var landscape_size: Vector2 = game.call("_responsive_panel_dimensions", Vector2(640.0, 360.0), 560.0)
	if not _expect(is_equal_approx(landscape_size.x, 500.0) and is_equal_approx(landscape_size.y, 320.0),
			"Short landscape dimensions should cap width and fit available height."):
		return

	var overlay: Control = game.get("home_overlay")
	if not _expect(overlay != null and is_instance_valid(overlay), "Home menu should exist at startup."):
		return
	var panel := overlay.find_child("ResponsivePanel", true, false) as PanelContainer
	var scroll := overlay.find_child("ContentScroll", true, false) as ScrollContainer
	var menu := overlay.find_child("MenuContent", true, false) as VBoxContainer
	if not _expect(panel != null and panel.custom_minimum_size.x <= 500.0, "Home menu panel should use the capped responsive width."):
		return
	if not _expect(scroll != null, "Home menu content should be vertically scrollable."):
		return
	if not _expect(menu != null, "Home menu should use a vertical content layout."):
		return
	for child in menu.get_children():
		if child is Button and not _expect(child.custom_minimum_size.x == 0.0, "Menu buttons should use available width."):
			return

	game.call("_show_garage_screen")
	var garage_overlay: Control = game.get("home_overlay")
	if not _expect(garage_overlay.find_child("ContentScroll", true, false) != null, "Garage should use the same responsive scroll layout."):
		return
	game.call("_toggle_pause")
	var pause_overlay: Control = game.get("pause_panel")
	if not _expect(pause_overlay != null and pause_overlay.find_child("ScrollContainer", true, false) != null,
			"Pause menu should also scroll on short screens."):
		return
	game.call("_close_pause_menu")
	game.queue_free()
	await process_frame
	print("RESPONSIVE UI TESTS PASSED.")
	quit(0)
