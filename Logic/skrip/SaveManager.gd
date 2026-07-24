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

	write_save_data(data)
	#print("Point saved")


func load_game() -> void:
	var data := read_save_data()

	Point.point = int(data.get("point", 10000))

	#print("Point loaded:", Point.point)


func save_skill_level(skill_database: skill_obj) -> void:
	var data := read_save_data()
	var skill_levels := {}

	for skill_data in skill_database.skills:
		if skill_data == null:
			continue

		skill_levels[skill_data.id] = skill_data.level

	data["skills"] = skill_levels

	write_save_data(data)
	#print("Skill level saved")


func load_skill_level(skill_database: skill_obj) -> void:
	var data := read_save_data()

	if not data.has("skills"):
		#print("Belum ada data skill")
		return

	var skill_levels = data["skills"]

	for skill_data in skill_database.skills:
		if skill_data == null:
			continue

		if skill_levels.has(skill_data.id):
			skill_data.level = int(skill_levels[skill_data.id])

	#print("Skill level loaded")
	
func delete_current_save() -> void:
	var path := get_save_path()

	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Save slot", current_slot, "berhasil dihapus")
	else:
		print("Save slot", current_slot, "memang belum ada")
