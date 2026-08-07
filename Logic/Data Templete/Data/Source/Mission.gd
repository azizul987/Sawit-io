class_name Mission
extends Resource

enum RequirementType {
	TOTAL_POINT_REACHED,
	UPGRADE_LEVEL_REACHED
}

@export var id: String = "misi_baru"
@export var mission_name: String = "Misi Baru"
@export_multiline var description: String = "Deskripsi misi."
@export var reward_rebirth_point: int = 1
@export var is_completed: bool = false

@export_category("Requirements")
@export var requirement_type: RequirementType = RequirementType.TOTAL_POINT_REACHED
@export var target_value: float = 1000.0
@export var target_id: String = "" # Dipakai kalau butuh ngecek id upgrade tertentu
