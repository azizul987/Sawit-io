extends Node

var current_slot := 1
var default_slot := 1


func set_slot(slot: int) -> void:
	current_slot = slot
	#print("Slot aktif:", current_slot)


func create_new_slot(slot: int) -> void:
	current_slot = slot
	write_save_data({"point": 0})


func get_save_path() -> String:
	return "user://save_slot_%d.json" % current_slot


func read_save_data() -> Dictionary:
	var path := get_save_path()

	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())

	if data == null:
		return {}

	return data


func write_save_data(data: Dictionary) -> void:
	var file := FileAccess.open(get_save_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(data))


func save_game() -> void:
	var data := read_save_data()

	data["point"] = Point.point
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
	data["tipe_wilayah"]={
		"x":Point.TipeWilayahArray.x,
		"y":Point.TipeWilayahArray.y,
		"z":Point.TipeWilayahArray.z
	}
	write_save_data(data)
	#print("Point saved")


func load_game() -> void:
	var data := read_save_data()

	Point.point = float(data.get("point", 0))
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
		"x":7347.983,
		"y":8094.0,
		"z":1
	})
	Point.main_tree_camera=Vector3(
		float(cam_data1.get("x")),
		float(cam_data1.get("y")),
		float(cam_data1.get("z"))
	)
	
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


func save_skill_level(skill_database: skill_obj) -> void:
	var data := read_save_data()
	var skill_levels := {}
	var skill_isopens :={}
	for skill_data in skill_database.skills:
		if skill_data == null:
			continue
		skill_levels[skill_data.id] = skill_data.level
		skill_isopens[skill_data.id]=skill_data.is_open
	data["skills"] = skill_levels
	data["isopens"]=skill_isopens
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

	for skill_data in skill_database.skills:
		if skill_data == null:
			continue

		skill_data.level = int(skill_levels.get(skill_data.id, 0))
		skill_data.is_open = bool(skill_isopen.get(skill_data.id, skill_data.required_skill_ids.is_empty()))
	#print("Skill level loaded")
	
func delete_current_save() -> void:
	var path := get_save_path()

	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Save slot", current_slot, "berhasil dihapus")
	else:
		print("Save slot", current_slot, "memang belum ada")

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

func save_upgrades(db: UpgradeDatabase) -> void:
	var d := read_save_data(); var u := {}
	for up in db.upgrades: if up: u[up.upgrade_name] = {"level": up.current_level, "price": up.price}
	d["upgrades"] = u; write_save_data(d)

func load_upgrades(db: UpgradeDatabase) -> void:
	var u: Dictionary = read_save_data().get("upgrades", {})
	for up in db.upgrades: if up and u.has(up.upgrade_name):
		up.current_level = int(u[up.upgrade_name].level)
		up.price = float(u[up.upgrade_name].price)
