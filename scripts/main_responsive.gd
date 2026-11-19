extends "res://scripts/main.gd"
## Responsive menu layer for narrow Android screens and shorter viewports.

func _build_home_screen(screen: String) -> void:
	if home_overlay != null and is_instance_valid(home_overlay):
		home_overlay.queue_free()
	home_overlay = _create_fullscreen_menu_overlay()

	var viewport_size := get_viewport().get_visible_rect().size
	var panel_width := clampf(viewport_size.x - 40.0, 260.0, 500.0)
	var panel_height := clampf(viewport_size.y - 40.0, 300.0, 620.0)

	var safe_area := MarginContainer.new()
	safe_area.name = "ResponsiveSafeArea"
	safe_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_area.add_theme_constant_override("margin_left", 12)
	safe_area.add_theme_constant_override("margin_right", 12)
	safe_area.add_theme_constant_override("margin_top", 12)
	safe_area.add_theme_constant_override("margin_bottom", 12)
	home_overlay.add_child(safe_area)

	var center := CenterContainer.new()
	center.name = "ResponsiveCenter"
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	safe_area.add_child(center)

	var panel := PanelContainer.new()
	panel.name = "ResponsivePanel"
	panel.custom_minimum_size = Vector2(panel_width, panel_height)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.085, 0.13, 0.98)
	style.border_color = Color(0.22, 0.62, 0.82, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var scroll := ScrollContainer.new()
	scroll.name = "ContentScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	panel.add_child(scroll)

	var menu := VBoxContainer.new()
	menu.name = "MenuContent"
	menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu.add_theme_constant_override("separation", 8)
	scroll.add_child(menu)

	if screen == "home":
		_add_menu_heading(menu, "ONE MAN SQUAD", "OPEN WORLD  •  RACING  •  SURVIVAL")
		var welcome := Label.new()
		welcome.text = "Your next adventure starts here."
		welcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		welcome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		menu.add_child(welcome)
		_add_menu_button(menu, "PLAY / CONTINUE", _enter_game)
		_add_menu_button(menu, "GARAGE", _show_garage_screen)
		_add_menu_button(menu, "GAME MODES", _show_modes_screen)
		_add_menu_button(menu, "SETTINGS", _show_settings_screen)
		_add_menu_button(menu, "ABOUT", _show_about_screen)
		_add_menu_footer(menu, "Single-player foundation • Online features are planned")
	elif screen == "garage":
		_add_menu_heading(menu, "GARAGE", "Choose your available vehicle.")
		_add_menu_button(menu, "BLUE CITY SEDAN", func() -> void: _select_garage_vehicle(0))
		_add_menu_button(menu, "RED SPORT COUPE", func() -> void: _select_garage_vehicle(1))
		_add_menu_button(menu, "BACK TO MAIN MENU", _show_home_menu)
		_add_menu_footer(menu, "Vehicle customisation and upgrade workshop are planned for a later stage.")
	elif screen == "modes":
		_add_menu_heading(menu, "GAME MODES", "Choose an available experience.")
		_add_menu_button(menu, "OPEN WORLD — AVAILABLE", _enter_game)
		_add_menu_button(menu, "TIME TRIAL — AVAILABLE", func() -> void:
			_enter_game()
			status_label.text = "Enter a vehicle and choose Racing to begin the time trial."
		)
		var survival_note := Label.new()
		survival_note.text = "SURVIVAL ZONE — PLANNED"
		survival_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		survival_note.add_theme_color_override("font_color", Color(1.0, 0.76, 0.4))
		menu.add_child(survival_note)
		var online_note := Label.new()
		online_note.text = "ONLINE MULTIPLAYER — PLANNED"
		online_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		online_note.add_theme_color_override("font_color", Color(1.0, 0.76, 0.4))
		menu.add_child(online_note)
		_add_menu_button(menu, "BACK TO MAIN MENU", _show_home_menu)
	elif screen == "settings":
		_add_menu_heading(menu, "SETTINGS", "Adjust camera response.")
		var sensitivity_label := Label.new()
		sensitivity_label.text = "Camera sensitivity"
		sensitivity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		menu.add_child(sensitivity_label)
		var sensitivity := HSlider.new()
		sensitivity.min_value = 0.002
		sensitivity.max_value = 0.012
		sensitivity.step = 0.001
		sensitivity.value = float(save_config.get_value("settings", "camera_sensitivity", 0.006))
		sensitivity.custom_minimum_size = Vector2(0, 42)
		sensitivity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sensitivity.value_changed.connect(_set_camera_sensitivity)
		menu.add_child(sensitivity)
		_add_menu_button(menu, "BACK TO MAIN MENU", _show_home_menu)
	elif screen == "about":
		_add_menu_heading(menu, "ABOUT ONE MAN SQUAD", "An expanding open-world action and racing project.")
		var about_text := Label.new()
		about_text.text = "This build is the foundation stage. Open-world exploration and time trial are playable prototypes. Survival, online multiplayer, equipment workshop and expanded racing are not implemented yet."
		about_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		about_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		menu.add_child(about_text)
		_add_menu_button(menu, "BACK TO MAIN MENU", _show_home_menu)
	resume_menu_focus(menu)

func _add_menu_button(parent: VBoxContainer, label_text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(0, 54)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _toggle_pause() -> void:
	if pause_panel != null and is_instance_valid(pause_panel):
		_close_pause_menu()
		return
	get_tree().paused = true
	pause_panel = _create_fullscreen_menu_overlay()
	var viewport_size := get_viewport().get_visible_rect().size
	var panel_width := clampf(viewport_size.x - 40.0, 260.0, 500.0)
	var panel_height := clampf(viewport_size.y - 40.0, 300.0, 560.0)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_panel.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(panel_width, panel_height)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.085, 0.13, 0.98)
	style.border_color = Color(0.22, 0.62, 0.82, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	var menu := VBoxContainer.new()
	menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu.add_theme_constant_override("separation", 10)
	scroll.add_child(menu)
	_add_menu_heading(menu, "GAME PAUSED", "Your progress is stored locally on this device.")
	_add_menu_button(menu, "RESUME GAME", _close_pause_menu)
	_add_menu_button(menu, "SAVE PROGRESS", func() -> void:
		_save_progress()
		status_label.text = "Progress saved on this device."
	)
	_add_menu_button(menu, "MAIN MENU", _show_home_menu)
	_add_menu_button(menu, "RESTART SESSION", _restart_session)
	_add_menu_footer(menu, "One Man Squad  •  Offline mode")
	resume_menu_focus(menu)
