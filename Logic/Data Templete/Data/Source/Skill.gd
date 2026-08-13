class_name skill
extends Resource

enum EffectType {
	CLICK_POWER_ADD,
	CLICK_POWER_MULT,
	AUTO_POINT_PER_SEC,
	AUTO_POINT_MULT,
	DISCOUNT_UPGRADE,
	DOUBLE_HARVEST_CHANCE,
	MAGNET_RADIUS
}

@export var id: String
@export var skill_name: String
@export var Description:String
@export var max_level: int
@export var tree_position: Vector2
@export var required_skill_ids: Array[String] = []
@export var is_open: bool
@export var cost: Array[int] = []
@export var level: int = 0
@export var Icon: Texture2D = preload("res://temp tekture/skill_icons_by_quintino_pixels/24x24/skill_icons7.png")

@export_category("Skill Effect")
@export var effect_type: EffectType = EffectType.CLICK_POWER_ADD
@export var effect_value: float = 5.0 # Efek bonus dari skill ini
@export var level_descriptions: Array[String] = [] # Deskripsi per level (index 0 = level 1)

# Kembalikan deskripsi sesuai level sekarang.
# Kalau level 0 (belum dibeli) → pakai deskripsi level 1 sebagai preview.
# Kalau sudah MAX → pakai deskripsi level terakhir.
# Kalau level_descriptions kosong → kembalikan string kosong.
func get_current_description() -> String:
	if level_descriptions.is_empty():
		return ""
	var idx := clampi(level - 1, 0, level_descriptions.size() - 1)
	return level_descriptions[idx]
