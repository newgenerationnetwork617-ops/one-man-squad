extends RefCounted
class_name SquadVehicleCatalog
## Offline vehicle catalogue. Entries describe the first-release garage targets.

const VEHICLES := [
	{"id":"starter_sedan","name":"City Sedan","category":"everyday","scene":"res://scenes/starter_car.tscn","max_speed":17.0,"acceleration":10.0,"handling":1.7,"unlock_xp":0},
	{"id":"sport_coupe","name":"Sport Coupe","category":"sports","scene":"res://scenes/sport_car.tscn","max_speed":23.0,"acceleration":13.0,"handling":2.0,"unlock_xp":500},
	{"id":"grand_tourer","name":"Grand Tourer","category":"sports","scene":"","max_speed":25.0,"acceleration":12.0,"handling":1.8,"unlock_xp":1200},
	{"id":"street_supercar","name":"Street Supercar","category":"supercar","scene":"","max_speed":29.0,"acceleration":15.0,"handling":1.9,"unlock_xp":2400},
	{"id":"family_suv","name":"Family SUV","category":"suv","scene":"","max_speed":18.0,"acceleration":9.0,"handling":1.5,"unlock_xp":300},
	{"id":"trail_suv","name":"Trail SUV","category":"off_road","scene":"","max_speed":17.0,"acceleration":10.0,"handling":1.6,"unlock_xp":900},
	{"id":"rally_runner","name":"Rally Runner","category":"off_road","scene":"","max_speed":22.0,"acceleration":14.0,"handling":2.1,"unlock_xp":1800},
	{"id":"executive_sedan","name":"Executive Sedan","category":"everyday","scene":"","max_speed":20.0,"acceleration":10.5,"handling":1.7,"unlock_xp":700}
]

static func all_vehicles() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in VEHICLES:
		result.append(entry.duplicate(true))
	return result

static func get_vehicle(vehicle_id: String) -> Dictionary:
	for entry in VEHICLES:
		if entry.id == vehicle_id:
			return entry.duplicate(true)
	return {}

static func is_unlocked(vehicle_id: String, xp: int) -> bool:
	var entry := get_vehicle(vehicle_id)
	return not entry.is_empty() and xp >= int(entry.unlock_xp)

static func available_for_xp(xp: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in VEHICLES:
		if xp >= int(entry.unlock_xp):
			result.append(entry.duplicate(true))
	return result
