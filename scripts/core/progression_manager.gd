class_name SquadProgressionManager
extends RefCounted
## Deterministic offline progression. Rewards are earned through gameplay only.

const RANKS := [
	{"name": "Rookie", "minimum_xp": 0},
	{"name": "Rising Star", "minimum_xp": 250},
	{"name": "Challenger", "minimum_xp": 750},
	{"name": "Elite", "minimum_xp": 1600},
	{"name": "Champion", "minimum_xp": 3000},
	{"name": "Legend", "minimum_xp": 5200}
]

func rank_for_xp(xp: int) -> Dictionary:
	var selected: Dictionary = RANKS[0]
	for rank in RANKS:
		if xp >= int(rank["minimum_xp"]):
			selected = rank
	return selected.duplicate(true)

func level_for_xp(xp: int) -> int:
	return maxi(1, 1 + int(floor(float(maxi(0, xp)) / 250.0)))

func award(profile: Dictionary, xp: int, gold: int = 0, tokens: int = 0) -> Dictionary:
	var updated := profile.duplicate(true)
	var progress: Dictionary = updated.get("progress", {})
	progress["xp"] = maxi(0, int(progress.get("xp", 0)) + maxi(0, xp))
	progress["gold"] = maxi(0, int(progress.get("gold", 0)) + maxi(0, gold))
	progress["tokens"] = maxi(0, int(progress.get("tokens", 0)) + maxi(0, tokens))
	progress["level"] = level_for_xp(int(progress["xp"]))
	updated["progress"] = progress
	return updated

func unlocks_for_xp(xp: int) -> Array[String]:
	var unlocks: Array[String] = []
	if xp >= 250:
		unlocks.append("improved_home")
	if xp >= 750:
		unlocks.append("sports_car")
	if xp >= 1600:
		unlocks.append("premium_outfit")
	if xp >= 3000:
		unlocks.append("premium_home")
	if xp >= 5200:
		unlocks.append("elite_home")
	return unlocks
