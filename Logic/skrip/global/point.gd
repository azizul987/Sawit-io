extends Node


var point: float = 0.0
var base_point_per_click: float = 2.5
var point_per_click: float = 2.5
var auto_point_per_sec: float = 0.0
var auto_accumulator: float = 0.0
var cd = 1
var skill_tree_camera: Vector3
var main_tree_camera: Vector3
var is_skill_tree_open: bool = false


func _process(delta: float) -> void:
	if auto_point_per_sec > 0.0:
		auto_accumulator += auto_point_per_sec * delta
		if auto_accumulator >= 1.0:
			var earned: int = int(floor(auto_accumulator))
			auto_accumulator -= earned
			point += earned # Tambah poin langsung tanpa save berlebih tiap detik


func add_point(value):
	point += value 
	#print("Point sekarang: ", point)
	SaveManager.save_game()


func remove_point(value): 
	point -= value
	if point < 0:
		point = 0
	#print("Point sekarang: ", point)


# Fungsi raib & sakti untuk menghitung seluruh efek dari Upgrade maupun Skill!
func recalculate_stats(upgrades_list: Array = [], skills_list: Array = []) -> void:
	var total_click_add: float = base_point_per_click
	var total_click_mult: float = 1.0
	var total_auto_add: float = 0.0
	var total_auto_mult: float = 1.0

	# 1. Hitung efek dari semua Upgrade yang sudah distop/beli
	for up in upgrades_list:
		if up != null and up.current_level > 0:
			var val: float = up.effect_value * up.current_level
			if up.effect_type == 0: # CLICK_POWER_ADD
				total_click_add += val
			elif up.effect_type == 1: # CLICK_POWER_MULT
				total_click_mult += (val / 100.0) # Kalau misal isi 20, berarti +20%
			elif up.effect_type == 2: # AUTO_POINT_PER_SEC
				total_auto_add += val
			elif up.effect_type == 3: # AUTO_POINT_MULT
				total_auto_mult += (val / 100.0)

	# 2. Hitung juga efek dari Skill Tree yang aktif/terbuka
	for sk in skills_list:
		if sk != null and sk.level > 0:
			var val: float = sk.effect_value * sk.level
			if sk.effect_type == 0:
				total_click_add += val
			elif sk.effect_type == 1:
				total_click_mult += (val / 100.0)
			elif sk.effect_type == 2:
				total_auto_add += val
			elif sk.effect_type == 3:
				total_auto_mult += (val / 100.0)

	# 3. Terapkan hasil perhitungan baru ke statistik permainan!
	point_per_click = total_click_add * total_click_mult
	auto_point_per_sec = total_auto_add * total_auto_mult

	print("=== STATS RECALCULATED ===")
	print("Point Per Click: ", point_per_click)
	print("Auto Sawit / Sec: ", auto_point_per_sec)


func _input(event: InputEvent) -> void:
	if Debug.is_active():
		if event.is_action_pressed("add_coin"):
			Point.add_point(100)
		if event.is_action("delete_save"):
			SaveManager.delete_current_save()
