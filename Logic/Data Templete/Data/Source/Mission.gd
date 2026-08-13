class_name Mission
extends Resource

enum RequirementType {
	TOTAL_POINT_REACHED,
	UPGRADE_LEVEL_REACHED,
	WILAYAH_TERBUKA
}

@export var id: String = "misi_baru"
@export var mission_name: String = "Misi Baru"
@export_multiline var description: String = "Deskripsi misi."
@export var reward_rebirth_point: int = 1
@export var is_completed: bool = false

@export_category("Requirements")
@export var target_value: float = 1000.0
