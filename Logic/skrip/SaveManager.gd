extends Node

var current_slot := 1
var default_slot := 1


func set_slot(slot: int) -> void:
	current_slot = slot
	#print("Slot aktif:", current_slot)


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
	write_save_data(data)
	#print("Point saved")


func load_game() -> void:
	var data := read_save_data()

	Point.point = int(data.get("point", 10000))
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
	#print("Point loaded:", Point.point)


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
	print("Skill level saved")


func load_skill_level(skill_database: skill_obj) -> void:
	var data := read_save_data()

	if not data.has("skills"):
		#print("Belum ada data skill")
		return

	var skill_levels = data["skills"]
	var skill_isopen=data["isopens"]
	for skill_data in skill_database.skills:
		if skill_data == null:
			continue

		if skill_levels.has(skill_data.id): 
			skill_data.level = int(skill_levels[skill_data.id])
		if skill_isopen.has(skill_data.id):
			skill_data.is_open = bool(skill_isopen[skill_data.id])
	#print("Skill level loaded")
	
func delete_current_save() -> void:
	var path := get_save_path()

	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Save slot", current_slot, "berhasil dihapus")
	else:
		print("Save slot", current_slot, "memang belum ada")
