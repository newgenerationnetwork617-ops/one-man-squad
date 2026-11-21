extends Node
class_name SquadNPCRegistry
## Lightweight offline NPC registry and dialogue interaction service.
signal dialogue_started(npc_id: String, speaker: String, lines: Array)
signal dialogue_ended(npc_id: String)

var characters: Dictionary = {}
var active_npc_id := ""

func register_npc(npc_id: String, display_name: String, role: String, dialogue: Array[String]) -> bool:
	if npc_id.strip_edges().is_empty() or display_name.strip_edges().is_empty() or characters.has(npc_id):
		return false
	characters[npc_id] = {"name": display_name, "role": role, "dialogue": dialogue.duplicate(), "interactions": 0}
	return true

func get_npc(npc_id: String) -> Dictionary:
	return characters.get(npc_id, {}).duplicate(true)

func interact(npc_id: String) -> bool:
	if not characters.has(npc_id):
		return false
	var npc: Dictionary = characters[npc_id]
	active_npc_id = npc_id
	npc.interactions = int(npc.interactions) + 1
	characters[npc_id] = npc
	dialogue_started.emit(npc_id, str(npc.name), npc.dialogue.duplicate())
	return true

func close_dialogue() -> void:
	if active_npc_id.is_empty():
		return
	var previous := active_npc_id
	active_npc_id = ""
	dialogue_ended.emit(previous)

func nearby_npc_ids(origin: Vector3, max_distance: float, positions: Dictionary) -> Array[String]:
	var found: Array[String] = []
	for npc_id in positions:
		if positions[npc_id] is Vector3 and origin.distance_to(positions[npc_id]) <= max_distance and characters.has(npc_id):
			found.append(str(npc_id))
	return found
