class_name SquadProfileStore
extends RefCounted
## Offline profile storage with three slots, validation and one-step backup recovery.

const SLOT_COUNT := 3
const PROFILE_DIR := "user://profiles"

func _slot_path(slot: int) -> String:
	return "%s/slot_%d.cfg" % [PROFILE_DIR, slot]

func _backup_path(slot: int) -> String:
	return "%s/slot_%d.bak" % [PROFILE_DIR, slot]

func _valid_slot(slot: int) -> bool:
	return slot >= 1 and slot <= SLOT_COUNT

func default_profile(display_name: String = "Player") -> Dictionary:
	return {
		"identity": {"display_name": display_name, "outfit_id": "starter", "vehicle_id": "starter_sedan"},
		"progress": {"xp": 0, "gold": 0, "tokens": 0, "level": 1, "missions": []},
		"records": {"best_race_time": 0.0, "competition_wins": 0, "discoveries": 0},
		"settings": {"camera_sensitivity": 0.006, "graphics_quality": "medium", "subtitles": true},
		"meta": {"schema_version": 1, "created_unix": int(Time.get_unix_time_from_system()), "updated_unix": int(Time.get_unix_time_from_system())}
	}

func save_slot(slot: int, profile: Dictionary) -> Error:
	if not _valid_slot(slot):
		return ERR_INVALID_PARAMETER
	var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PROFILE_DIR))
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		return directory_error
	var config := ConfigFile.new()
	for section_variant in profile.keys():
		var section: String = str(section_variant)
		var values: Variant = profile[section_variant]
		if values is Dictionary:
			for key_variant in values.keys():
				config.set_value(section, str(key_variant), values[key_variant])
		var meta: Dictionary = profile.get("meta", {})
	meta["schema_version"] = 1
	meta["updated_unix"] = int(Time.get_unix_time_from_system())
	profile["meta"] = meta
	config.set_value("meta", "schema_version", 1)
	config.set_value("meta", "updated_unix", meta["updated_unix"])
	var temporary_path := _slot_path(slot) + ".tmp"
	var error := config.save(temporary_path)
	if error != OK:
		return error
	var final_path := _slot_path(slot)
	if FileAccess.file_exists(final_path):
		var old_data := FileAccess.get_file_as_bytes(final_path)
		var backup := FileAccess.open(_backup_path(slot), FileAccess.WRITE)
		if backup == null:
			return ERR_CANT_OPEN
		backup.store_buffer(old_data)
		backup.close()
	var absolute_temp := ProjectSettings.globalize_path(temporary_path)
	var absolute_final := ProjectSettings.globalize_path(final_path)
	var rename_error := DirAccess.rename_absolute(absolute_temp, absolute_final)
	return rename_error

func load_slot(slot: int) -> Dictionary:
	if not _valid_slot(slot):
		return {"ok": false, "error": "invalid_slot", "profile": {}}
	var config := ConfigFile.new()
	var error := config.load(_slot_path(slot))
	if error != OK:
		var backup_config := ConfigFile.new()
		var backup_error := backup_config.load(_backup_path(slot))
		if backup_error != OK:
			return {"ok": false, "error": "not_found_or_corrupt", "profile": {}}
		config = backup_config
	var profile := {}
	for section in ["identity", "progress", "records", "settings", "meta"]:
		var values := {}
		for key in config.get_section_keys(section):
			values[key] = config.get_value(section, key)
		profile[section] = values
	return {"ok": true, "error": "", "profile": profile}

func delete_slot(slot: int) -> Error:
	if not _valid_slot(slot):
		return ERR_INVALID_PARAMETER
	for path in [_slot_path(slot), _backup_path(slot), _slot_path(slot) + ".tmp"]:
		if FileAccess.file_exists(path):
			var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
			if error != OK:
				return error
	return OK

func list_slots() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for slot in range(1, SLOT_COUNT + 1):
		var loaded := load_slot(slot)
		var profile: Dictionary = loaded.get("profile", {})
		var identity: Dictionary = profile.get("identity", {})
		var progress: Dictionary = profile.get("progress", {})
		result.append({
			"slot": slot,
			"occupied": bool(loaded.get("ok", false)),
			"display_name": str(identity.get("display_name", "")),
			"level": int(progress.get("level", 1))
		})
	return result
