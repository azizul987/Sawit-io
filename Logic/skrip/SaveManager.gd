extends Node

var current_slot := -1
var default_slot := 1
var autosave_enabled := false

func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = 5.0
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_on_autosave_timeout)
	add_child(timer)

func _on_autosave_timeout() -> void:
	# Jangan pernah membuat save baru dari state global saat berada di menu.
	if not autosave_enabled or current_slot < 1:
		return
	if not FileAccess.file_exists(get_save_path()):
		return
	save_game()

func set_autosave_enabled(enabled: bool) -> void:
	autosave_enabled = enabled

func clear_active_slot() -> void:
	autosave_enabled = false
	current_slot = -1
	
func set_slot(slot: int) -> void:
	current_slot = slot
	#print("Slot aktif:", current_slot)

func create_new_slot(slot: int) -> void:
	var path := "user://save_slot_%d.json" % slot
	var data := {
		"slot_name": "Slot %d" % slot,   # <-- BARU
		"point": 1.0,
		"total_point_earned": 0.0,
		"rebirth_point": 0,
		"var idx_mision_now": 0,
		"skill_tree_camera": {"x": 0.0, "y": 0.0, "z": 1.4},
		"main_camera": {"x": 7508.0, "y": 8765.0, "z": 1.0},
		"tipe_wilayah_terbuka": 2,
		"tipe_wilayah": {"x": 0, "y": 0, "z": 1},
		"win_progress_percent": 2.0
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))


func get_save_path() -> String:
	return "user://save_slot_%d.json" % current_slot


func get_all_slots() -> Array:
	var slots := []
	for i in range(1, 100):
		var file_path = "user://save_slot_%d.json" % i
		if FileAccess.file_exists(file_path):
			var data := get_save_data(i)
			data["slot"] = i
			slots.append(data)
	return slots


func get_save_data(slot: int) -> Dictionary:
	var path := "user://save_slot_%d.json" % slot
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	var json := JSON.new()
	var err := json.parse(content)
	if err != OK:
		return {}

	var result = json.get_data()
	if result is Dictionary:
		return result
	return {}


func get_active_slot_display_text() -> String:
	return "Slot %d" % current_slot


func read_save_data() -> Dictionary:
	if current_slot < 1:
		return {}
	var path := get_save_path()

	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())

	if data == null:
		return {}

	return data


func write_save_data(data: Dictionary) -> void:
	if current_slot < 1:
		return
	var file := FileAccess.open(get_save_path(), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))


func save_game() -> void:
	if current_slot < 1:
		return
	var data := read_save_data()
	data["modal_awal"]=Point.modal_awal
	data["point"] = Point.point
	data["total_point_earned"] = Point.total_point_earned
	data["rebirth_point"] = Point.rebirth_point
	data['var idx_mision_now']=Point.idx_mision_now
	data["pps_default"] = Point.pps_default
	

	data["skill_tree_camera"]={
		"x":Point.skill_tree_camera.x,
		"y":Point.skill_tree_camera.y,
		"z":Point.skill_tree_camera.z
	}
	data["main_camera"]={
		"x":Point.main_tree_camera.x,
		"y":Point.main_tree_camera.y,
		"z":Point.main_tree_camera.z
	}
	data["tipe_wilayah_terbuka"]=Point.tipe_wilayah_terbuka
	data["tipe_wilayah"]={
		"x":Point.TipeWilayahArray.x,
		"y":Point.TipeWilayahArray.y,
		"z":Point.TipeWilayahArray.z
	}

	# Simpan progress menuju kondisi menang agar bisa langsung ditampilkan di menu slot.
	var win_progress := _calculate_runtime_win_progress()
	if win_progress >= 0.0:
		data["win_progress_percent"] = win_progress
	
	write_save_data(data)
	#print("Point saved")


func load_game() -> void:
	if current_slot < 1:
		return
	var data := read_save_data()
	Point.modal_awal=float(data.get("modal_awal",1))
	Point.point = float(data.get("point", Point.modal_awal))
	Point.total_point_earned = float(data.get("total_point_earned", 0))
	Point.rebirth_point = int(data.get("rebirth_point", 0))
	
	Point.idx_mision_now=int(data.get("var idx_mision_now",0))
	
	var cam_data:Dictionary=data.get("skill_tree_camera",{
		"x":0.0,
		"y":0.0,
		"z":1.4
	})
	Point.skill_tree_camera=Vector3(
		float(cam_data.get("x")),
		float(cam_data.get("y")),
		float(cam_data.get("z"))
	)
	var cam_data1=data.get("main_camera",{
		"x":7508.0,
		"y":8765.0,
		"z":1
	})
	Point.main_tree_camera=Vector3(
		float(cam_data1.get("x")),
		float(cam_data1.get("y")),
		float(cam_data1.get("z"))
	)
	
	Point.tipe_wilayah_terbuka=int(data.get("tipe_wilayah_terbuka", 2))
	var tipewilayah=data.get("tipe_wilayah",{
		"x":0,
		"y":0,
		"z":1
	})
	Point.TipeWilayahArray=Vector3i(
		int(tipewilayah.get("x")),#prov
		int(tipewilayah.get("y")),
		int(tipewilayah.get("z"))
		)
	
	var raw_pps = data.get("pps_default", [0,0,0])
	var arr: Array[int] = []
	for v in raw_pps:
		arr.append(int(v))
	Point.pps_default = arr


func save_skill_level(skill_database: skill_obj) -> void:
	var data := read_save_data()
	var skill_levels := {}
	var skill_isopens := {}
	var skill_locked := {}
	for skill_data in skill_database.skills:
		if skill_data == null:
			continue
		skill_levels[skill_data.id] = skill_data.level
		skill_isopens[skill_data.id] = skill_data.is_open
		skill_locked[skill_data.id] = skill_data.locked_level
	data["skills"] = skill_levels
	data["isopens"] = skill_isopens
	data["skills_locked"] = skill_locked
	write_save_data(data)
	#print("Skill level saved")
	
func save_status_wilayah(daftar_wilayah: Array) -> void:
	var save_data: Dictionary = read_save_data()
	var status_wilayah: Dictionary = {}

	for node_wilayah in daftar_wilayah:
		if not is_instance_valid(node_wilayah):
			continue

		var data_wilayah: Wilayah = node_wilayah.get("data") as Wilayah

		if data_wilayah == null:
			continue

		if data_wilayah.id_wilayah == &"":
			push_warning(
				"Wilayah %s tidak memiliki id_wilayah"
				% node_wilayah.name
			)
			continue

		status_wilayah[str(data_wilayah.id_wilayah)] = \
			data_wilayah.terbuka_default

	save_data["wilayah"] = status_wilayah
	write_save_data(save_data)
	
func load_status_wilayah(daftar_wilayah: Array) -> void:
	var save_data: Dictionary = read_save_data()
	var status_wilayah: Dictionary = save_data.get("wilayah", {})

	for node_wilayah in daftar_wilayah:
		if not is_instance_valid(node_wilayah):
			continue

		var data_wilayah: Wilayah = node_wilayah.get("data") as Wilayah

		if data_wilayah == null:
			continue

		var id: String = str(data_wilayah.id_wilayah)

		if status_wilayah.has(id):
			data_wilayah.terbuka_default = bool(status_wilayah[id])
		elif not data_wilayah.resource_path.is_empty():
			var clean_res := ResourceLoader.load(data_wilayah.resource_path, "", ResourceLoader.CACHE_MODE_IGNORE) as Wilayah
			if clean_res != null:
				data_wilayah.terbuka_default = clean_res.terbuka_default

		if node_wilayah.has_method("perbarui_tampilan"):
			node_wilayah.perbarui_tampilan()

func load_skill_level(skill_database: skill_obj) -> void:
	var data := read_save_data()
	var skill_levels: Dictionary = data.get("skills", {})
	var skill_isopen: Dictionary = data.get("isopens", {})
	var skill_locked: Dictionary = data.get("skills_locked", {})

	for skill_data in skill_database.skills:
		if skill_data == null:
			continue

		skill_data.level = int(skill_levels.get(skill_data.id, 0))
		skill_data.is_open = bool(skill_isopen.get(skill_data.id, skill_data.required_skill_ids.is_empty()))
		skill_data.locked_level = int(skill_locked.get(skill_data.id, 0))
	#print("Skill level loaded")
	
func delete_current_save() -> void:
	var path := get_save_path()

	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Save slot", current_slot, "berhasil dihapus")
	else:
		print("Save slot", current_slot, "memang belum ada")

func delete_all_saves() -> void:
	# Matikan autosave dulu agar file yang baru dihapus tidak dibuat ulang.
	autosave_enabled = false
	var slots := get_all_used_slots()
	for s in slots:
		var path := "user://save_slot_%d.json" % s
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	current_slot = -1
	print("Semua save data berhasil dihapus.")

func get_all_used_slots() -> Array[int]:
	var slots: Array[int] = []
	var dir := DirAccess.open("user://")
	if dir == null:
		return slots
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.begins_with("save_slot_") and file_name.ends_with(".json"):
			var num_str := file_name.trim_prefix("save_slot_").trim_suffix(".json")
			if num_str.is_valid_int():
				slots.append(int(num_str))
		file_name = dir.get_next()
	dir.list_dir_end()
	slots.sort()
	return slots

func get_next_available_slot() -> int:
	var used_slots := get_all_used_slots()
	var next_slot := 1
	while used_slots.has(next_slot):
		next_slot += 1
	return next_slot

func delete_slot(slot: int) -> void:
	var path := "user://save_slot_%d.json" % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	if slot == current_slot:
		clear_active_slot()

func save_upgrades(db: UpgradeDatabase) -> void:
	var d := read_save_data(); var u := {}
	for up in db.upgrades: if up: u[up.upgrade_name] = {"level": up.current_level, "price": up.price}
	d["upgrades"] = u; write_save_data(d)

func load_upgrades(db: UpgradeDatabase) -> void:
	var u: Dictionary = read_save_data().get("upgrades", {})
	var c := ResourceLoader.load(db.resource_path, "", ResourceLoader.CACHE_MODE_IGNORE) as UpgradeDatabase
	for i in db.upgrades.size():
		var up := db.upgrades[i]; if not up: continue
		if u.has(up.upgrade_name):
			up.current_level = int(u[up.upgrade_name].level)
			up.price = float(u[up.upgrade_name].price)
		elif c and c.upgrades[i]:
			up.current_level = c.upgrades[i].current_level
			up.price = c.upgrades[i].price
			

func get_slot_name(slot: int) -> String:
	var data := get_save_data(slot)
	return data.get("slot_name", "Slot %d" % slot)

func set_slot_name(slot: int, new_name: String) -> void:
	var path := "user://save_slot_%d.json" % slot
	if not FileAccess.file_exists(path):
		return
	var data := get_save_data(slot)
	data["slot_name"] = new_name
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))


func get_slot_win_progress(slot: int) -> float:
	var data := get_save_data(slot)
	if data.is_empty():
		return 0.0

	if data.has("win_progress_percent"):
		return clampf(float(data["win_progress_percent"]), 0.0, 100.0)

	# Fallback untuk save lama yang belum pernah menyimpan progress menang.
	# Bagian wilayah + tier masih bisa dihitung dari data save; bagian pohon
	# akan terisi akurat setelah save tersebut dimainkan dan tersimpan lagi.
	var tipe_data: Dictionary = data.get("tipe_wilayah", {})
	var opened_regions := (
		int(tipe_data.get("x", 0))
		+ int(tipe_data.get("y", 0))
		+ int(tipe_data.get("z", 1))
	)
	var territory_progress := clampf(float(opened_regions) / 17.0, 0.0, 1.0)
	var tier := int(data.get("tipe_wilayah_terbuka", 2))
	var tier_progress := clampf(float(2 - tier) / 2.0, 0.0, 1.0)

	return clampf((territory_progress + tier_progress) / 3.0 * 100.0, 0.0, 100.0)


func _calculate_runtime_win_progress() -> float:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return -1.0

	var map_node := current_scene.get_node_or_null("map")
	var upgrade_ui := get_tree().get_first_node_in_group("upgrade_ui")
	if map_node == null or upgrade_ui == null:
		return -1.0

	var regions = map_node.get("daftar_wilayah")
	if not regions is Array:
		return -1.0

	var valid_regions := 0
	var opened_regions := 0
	for wilayah in regions:
		if not is_instance_valid(wilayah):
			continue

		var data_wilayah = wilayah.get("data")
		if data_wilayah == null:
			continue

		valid_regions += 1
		if data_wilayah.terbuka_default:
			opened_regions += 1

	if valid_regions <= 0:
		return -1.0

	var upgrade_database = upgrade_ui.get("upgrade_database")
	if upgrade_database == null:
		return -1.0

	var palm_progress := 0.0
	var found_palm_upgrade := false
	for upgrade_data in upgrade_database.upgrades:
		if upgrade_data == null:
			continue
		if upgrade_data.upgrade_name == "Jumlah Sawit" or upgrade_data.upgrade_name == "Pohon Sawit":
			found_palm_upgrade = true
			if upgrade_data.max_level > 0:
				palm_progress = clampf(
					float(upgrade_data.current_level) / float(upgrade_data.max_level),
					0.0,
					1.0
				)
			break

	if not found_palm_upgrade:
		return -1.0

	var territory_progress := float(opened_regions) / float(valid_regions)
	# 2=Kecamatan (0%), 1=Kabupaten (50%), 0=Provinsi (100%).
	var tier_progress := clampf(float(2 - Point.tipe_wilayah_terbuka) / 2.0, 0.0, 1.0)

	# Tiga syarat utama kondisi menang diberi bobot sama:
	# tier Provinsi, seluruh wilayah terbuka, dan pohon sawit mencapai maksimum.
	var progress := (territory_progress + tier_progress + palm_progress) / 3.0
	return clampf(round(progress * 1000.0) / 10.0, 0.0, 100.0)
