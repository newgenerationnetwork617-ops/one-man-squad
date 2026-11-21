extends RefCounted
class_name SquadCharacterCustomizer
## Applies lightweight, offline character appearance choices to the existing procedural player model.

const SKIN_TONES := {
	"warm_brown": Color(0.68, 0.43, 0.29),
	"deep_brown": Color(0.34, 0.19, 0.12),
	"light_brown": Color(0.82, 0.61, 0.43),
	"medium": Color(0.57, 0.35, 0.23)
}
const OUTFITS := {
	"navy": Color(0.08, 0.22, 0.42),
	"charcoal": Color(0.12, 0.14, 0.17),
	"olive": Color(0.22, 0.28, 0.16),
	"burgundy": Color(0.34, 0.08, 0.13)
}
const TROUSERS := {
	"dark": Color(0.12, 0.15, 0.2),
	"blue": Color(0.12, 0.2, 0.34),
	"tan": Color(0.42, 0.31, 0.2)
}
const HAIR_STYLES := ["short", "rounded", "shaved"]

static func defaults() -> Dictionary:
	return {"display_name": "Player", "skin_tone": "warm_brown", "outfit": "navy", "trousers": "dark", "hair_style": "short", "hair_color": "black"}

static func apply_to_player(player: Node3D, appearance: Dictionary) -> bool:
	if not is_instance_valid(player):
		return false
	var data := defaults()
	for key in appearance:
		data[key] = appearance[key]
	if not SKIN_TONES.has(data.skin_tone) or not OUTFITS.has(data.outfit) or not TROUSERS.has(data.trousers) or not HAIR_STYLES.has(data.hair_style):
		return false
	_set_material_color(player, ["Head"], SKIN_TONES[data.skin_tone])
	_set_material_color(player, ["Torso", "LeftArm", "RightArm"], OUTFITS[data.outfit])
	_set_material_color(player, ["LeftLeg", "RightLeg"], TROUSERS[data.trousers])
	var hair := player.get_node_or_null("Hair") as MeshInstance3D
	if hair != null:
		hair.visible = data.hair_style != "shaved"
		hair.scale = Vector3(1.0, 0.48 if data.hair_style == "short" else 0.62, 1.0)
		var hair_material := StandardMaterial3D.new()
		hair_material.albedo_color = Color(0.045, 0.035, 0.03) if data.hair_color == "black" else Color(0.22, 0.12, 0.06)
		hair.material_override = hair_material
	return true

static func _set_material_color(root: Node, paths: Array[String], color: Color) -> void:
	for path in paths:
		var mesh := root.get_node_or_null(path) as MeshInstance3D
		if mesh == null:
			continue
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.82
		mesh.material_override = material
