class_name UpgradeData
extends Resource

enum EffectType {
	CLICK_POWER_ADD,        # Tambah poin per klik (contoh: +1.0 per level)
	CLICK_POWER_MULT,       # Pengganda poin klik (contoh: x1.2 atau +20% per level)
	AUTO_POINT_PER_SEC,     # Poin otomatis tiap detik / Idle (contoh: +2.5/detik per level)
	AUTO_POINT_MULT,        # Pengganda poin idle (contoh: x1.5 per level)
	DISCOUNT_UPGRADE        # Diskon harga beli (contoh: 0.05 untuk diskon 5% per level)
}

@export_category("Upgrade Information")
@export var upgrade_name: String = "Upgrade Baru"
@export_multiline var description: String = "Deskripsi upgrade skill ini."
@export var price: float = 10.0
@export var price_multiplier: float = 1.3 # Harga naik 1.3x lipat tiap beli
@export var icon: Texture2D

@export_category("Upgrade Effect")
@export var effect_type: EffectType = EffectType.CLICK_POWER_ADD
@export var effect_value: float = 1.0 # Angka efek yang bertambah per level

@export_category("Level")
@export var current_level: int = 0
@export var max_level: int = 10

@export_category("Requirement")
@export var required_upgrade: UpgradeData
@export var required_level: int = 0


func is_unlocked() -> bool:
	return required_upgrade == null or required_upgrade.current_level >= required_level


func can_upgrade() -> bool:
	return current_level < max_level


func upgrade() -> bool:
	if not can_upgrade():
		return false

	current_level += 1
	# Naikkan harga untuk pembelian berikutnya
	price = round(price * price_multiplier)
	return true


func is_max_level() -> bool:
	return current_level >= max_level
