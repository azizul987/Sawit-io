extends Node

signal  point_change(point_per_click)

var point: float = 0.0
var total_point_earned: float = 0.0

var rebirth_point: int = 1
var base_point_per_click: float = 0.0
var point_per_click: float = 0.0
var cd = 1
var skill_tree_camera: Vector3=Vector3(0,0,1.4)
var main_tree_camera: Vector3
var is_skill_tree_open: bool = false
var upgrade_discount: float = 0.0
var magnet_radius: float = 0.0
var panen_ganda_chance: float = 0.0
var TipeWilayahArray:Vector3i#[prov,kab,kec]
var tipe_wilayah_terbuka: int = 2 # 0: PROVINSI, 1: KABUPATEN, 2: KECAMATAN

var idx_mision_now:int=0


signal pps_updated(new_pps)
var points_per_second: float = 0.0
var _pps_buffer: float = 0.0 
var _pps_interval: float = 1.0 
var _pps_timer: float = 0.0 

func _process(delta: float) -> void:
	_update_pps(delta)

func add_point(value):
	point += value
	_pps_buffer += value
	if point > 1e300:
		point = 1e300
	total_point_earned += value
	if total_point_earned > 1e300:
		total_point_earned = 1e300


func remove_point(value): 
	point -= value
	if point < 0 or is_nan(point):
		point = 0
	if point > 1e300:
		point = 1e300
	#print("Point sekarang: ", point)

func add_rebirth_point(value: int):
	rebirth_point += value

func remove_rebirth_point(value: int):
	rebirth_point -= value
	if rebirth_point < 0:
		rebirth_point = 0


# Fungsi raib & sakti untuk menghitung seluruh efek dari Upgrade maupun Skill!
func recalculate_stats(upgrades_list: Array = [], skills_list: Array = []) -> void:
	if upgrades_list.is_empty():
		var up_db = load("res://Logic/Data Templete/Data/ress/updatedatabase.tres")
		if up_db: upgrades_list = up_db.upgrades
	if skills_list.is_empty():
		var sk_db = load("res://Logic/Data Templete/Data/ress/Skill_Database_place.tres")
		if sk_db: skills_list = sk_db.skills

	var total_click_add: float = base_point_per_click
	var total_click_mult: float = 1.0
	
	upgrade_discount = 0.0
	magnet_radius = 0.0
	panen_ganda_chance = 0.0

	# 1. Hitung efek dari semua Upgrade yang sudah distop/beli
	for up in upgrades_list:
		if up != null and up.current_level > 0:
			var val: float = up.effect_value * up.current_level
			if up.effect_type == 0: # CLICK_POWER_ADD
				total_click_add += val
			elif up.effect_type == 1: # CLICK_POWER_MULT
				total_click_mult += (val / 100.0) # Kalau misal isi 20, berarti +20%

	# 2. Hitung juga efek dari Skill Tree yang aktif/terbuka
	for sk in skills_list:
		if sk != null and sk.level > 0:
			var val: float = sk.effect_value * sk.level
			if sk.effect_type == 0:
				total_click_add += val
			elif sk.effect_type == 1:
				total_click_mult += (val / 100.0)
			elif sk.effect_type == 4:
				upgrade_discount += val
			elif sk.effect_type == 5:
				panen_ganda_chance += val
			elif sk.effect_type == 6:
				magnet_radius += val

	# 3. Terapkan hasil perhitungan baru ke statistik permainan!
	point_per_click = total_click_add * total_click_mult



func _input(event: InputEvent) -> void:
	if Debug.is_active():
		if event.is_action_pressed("add_coin"):
			# Gunakan penulisan .0 atau e supaya dibaca float. Jika tidak, akan dianggap Integer 64-bit yang limitnya cuma 9.22e18 dan otomatis minus (overflow)
			Point.add_point(1e240) 
		if event.is_action("delete_save"):
			SaveManager.delete_current_save()




	



func get_suffix(i: int) -> String:
	var s: Array[String] = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]
	if i < s.size():
		return s[i]
	
	var alpha_idx = i - s.size()
	# Generate a, b, c... z, aa, ab, ac... (mendukung sampai 1e300 ke atas)
	var a_val = 97 # 'a' in ASCII
	if alpha_idx < 26:
		return String.chr(a_val + alpha_idx)
	else:
		var first = alpha_idx / 26 - 1
		var second = alpha_idx % 26
		return String.chr(a_val + first) + String.chr(a_val + second)


func format_num(val: float) -> String:
	var n: float = val
	var i: int = 0
	
	while n >= 1000.0:
		n /= 1000.0
		i += 1
		
	if i == 0: return "%.0f" % floor(n)
	var suffix = get_suffix(i)
	var t: String = "%.1f" % n
	if t.ends_with(".0"):
		return ("%.0f" % n) + suffix
	return t + suffix


func _update_pps(delta: float) -> void:
	_pps_timer += delta

	if _pps_timer >= _pps_interval:
		points_per_second = _pps_buffer / _pps_timer
		pps_updated.emit(points_per_second)

		point_change.emit(point_per_click)

		_pps_buffer = 0.0
		_pps_timer = 0.0
