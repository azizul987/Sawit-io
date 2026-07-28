class_name skill
extends Resource

enum EffectType {
	CLICK_POWER_ADD,
	CLICK_POWER_MULT,
	AUTO_POINT_PER_SEC,
	AUTO_POINT_MULT,
	DISCOUNT_UPGRADE
}

@export var id: String
@export var skill_name: String
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
