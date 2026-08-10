class_name UpgradeData
extends Resource

enum EffectType {
	CLICK_POWER_ADD,        # 0: Tambah poin per klik / Jumlah Sawit
	CLICK_POWER_MULT,       # 1: Pengganda poin klik / Eskalasi Harga (contoh: +15% per level)
	AUTO_POINT_PER_SEC,     # 2: Poin otomatis / Rekrut Buruh (dengan sistem bagi hasil)
	AUTO_POINT_MULT,        # 3: Pengganda poin idle
	DISCOUNT_UPGRADE,       # 4: Diskon harga beli
	WORKER_SPEED_INTEL,     # 5: Work Life Balance (Meningkatkan speed & kepintaran buruh)
	TERRITORY_MULTIPLIER,   # 6: Agregat Harga (Multiplier harga berdasar wilayah terbuka)
	CRITICAL_HARVEST        # 7: Sawit Super (Peluang 5% untuk mendapat 10x lipat)
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

func get_discounted_price() -> float:
	var discounted = price * (1.0 - (Point.upgrade_discount / 100.0))
	return max(0.0, discounted)


func can_upgrade() -> bool:
	return current_level < max_level


func upgrade() -> bool:
	if not can_upgrade():
		return false

	current_level += 1
	# Naikkan harga untuk pembelian berikutnya
	price = price * price_multiplier
	if price > 1e300:
		price = 1e300
	else:
		price = ceil(price)
	return true


func is_max_level() -> bool:
	return current_level >= max_level
