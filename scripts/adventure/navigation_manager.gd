extends Node
class_name SquadNavigationManager
## Offline map markers, favourites and waypoint guidance data.
signal destination_changed(marker_id: String)

var markers: Dictionary = {}
var favourites: Array[String] = []
var destination_id := ""

func add_marker(marker_id: String, label: String, category: String, position: Vector3) -> bool:
	if marker_id.is_empty() or label.is_empty() or markers.has(marker_id):
		return false
	markers[marker_id] = {"label": label, "category": category, "position": position, "discovered": false}
	return true

func discover(marker_id: String) -> bool:
	if not markers.has(marker_id):
		return false
	markers[marker_id].discovered = true
	return true

func toggle_favourite(marker_id: String) -> bool:
	if not markers.has(marker_id):
		return false
	if favourites.has(marker_id):
		favourites.erase(marker_id)
	else:
		favourites.append(marker_id)
	return true

func set_destination(marker_id: String) -> bool:
	if not markers.has(marker_id):
		return false
	destination_id = marker_id
	destination_changed.emit(marker_id)
	return true

func guidance_from(position: Vector3) -> Dictionary:
	if destination_id.is_empty() or not markers.has(destination_id):
		return {}
	var target: Vector3 = markers[destination_id].position
	var offset := target - position
	return {"marker_id": destination_id, "label": markers[destination_id].label, "distance": offset.length(), "direction": Vector2(offset.x, offset.z).normalized(), "position": target}

func visible_markers(show_undiscovered: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for marker_id in markers:
		var marker: Dictionary = markers[marker_id]
		if show_undiscovered or bool(marker.discovered):
			var item := marker.duplicate(true)
			item["id"] = marker_id
			item["favourite"] = favourites.has(marker_id)
			result.append(item)
	return result
