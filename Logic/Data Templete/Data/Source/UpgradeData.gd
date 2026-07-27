class_name UpgradeData
extends Resource

@export_category("Upgrade Information")
@export var upgrade_name: String = "Upgrade Baru"
@export var price: float = 10.0
@export var icon: Texture2D

@export_category("Level")
@export var current_level: int = 0
@export var max_level: int = 10


func can_upgrade() -> bool:
	return current_level < max_level


func upgrade() -> bool:
	if not can_upgrade():
		return false

	current_level += 1
	return true


func is_max_level() -> bool:
	return current_level >= max_level
