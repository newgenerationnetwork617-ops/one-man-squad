extends Node
class_name SquadMissionManager
## Offline objective progression for exploration missions.
signal mission_started(mission_id: String)
signal objective_updated(mission_id: String, objective_index: int, progress: int, target: int)
signal mission_completed(mission_id: String, xp_reward: int, gold_reward: int)

var missions: Dictionary = {}
var active_mission_id := ""

func register_mission(mission: Dictionary) -> bool:
	var mission_id := str(mission.get("id", ""))
	var objectives: Array = mission.get("objectives", [])
	if mission_id.is_empty() or missions.has(mission_id) or objectives.is_empty():
		return false
	var copy := mission.duplicate(true)
	copy["status"] = "available"
	copy["objective_index"] = 0
	copy["progress"] = 0
	missions[mission_id] = copy
	return true

func start_mission(mission_id: String) -> bool:
	if not missions.has(mission_id) or str(missions[mission_id].status) != "available" or not active_mission_id.is_empty():
		return false
	active_mission_id = mission_id
	missions[mission_id].status = "active"
	missions[mission_id].objective_index = 0
	missions[mission_id].progress = 0
	mission_started.emit(mission_id)
	return true

func advance_objective(event_type: String, target_id: String, amount: int = 1) -> bool:
	if active_mission_id.is_empty() or amount <= 0:
		return false
	var mission: Dictionary = missions[active_mission_id]
	var index := int(mission.objective_index)
	var objective: Dictionary = mission.objectives[index]
	if str(objective.get("type", "")) != event_type or str(objective.get("target", "")) != target_id:
		return false
	var target_count := maxi(1, int(objective.get("count", 1)))
	mission.progress = mini(target_count, int(mission.progress) + amount)
	objective_updated.emit(active_mission_id, index, int(mission.progress), target_count)
	if int(mission.progress) >= target_count:
		index += 1
		mission.objective_index = index
		mission.progress = 0
		if index >= mission.objectives.size():
			mission.status = "completed"
			var completed_id := active_mission_id
			active_mission_id = ""
			mission_completed.emit(completed_id, int(mission.get("xp_reward", 0)), int(mission.get("gold_reward", 0)))
		return true
	return true

func get_active_mission() -> Dictionary:
	if active_mission_id.is_empty():
		return {}
	return missions[active_mission_id].duplicate(true)
