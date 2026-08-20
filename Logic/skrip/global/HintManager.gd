extends Node

# Baca hints_shown langsung dari save aktif (tanpa cache)
# supaya otomatis ikut slot yang sedang aktif

# Panggil ini dari mana saja untuk tampilkan hint sekali
# Contoh: HintManager.show_hint("skill_tree_open", "Klik kiri beli skill, klik kanan refund!")
func show_hint(id: String, text: String) -> void:
	var data := SaveManager.read_save_data()
	var hints_shown: Dictionary = data.get("hints_shown", {})
	if hints_shown.get(id, false):
		return
	hints_shown[id] = true
	data["hints_shown"] = hints_shown
	SaveManager.write_save_data(data)
	_display(text)

# Reset semua hint (misal saat new game / delete save)
func reset_hints() -> void:
	var data := SaveManager.read_save_data()
	data["hints_shown"] = {}
	SaveManager.write_save_data(data)

func _display(text: String) -> void:
	var nodes := get_tree().get_nodes_in_group("hint_display")
	for node in nodes:
		var label = node.get_child(0).get_child(0)
		label.bbcode_enabled = true
		label.text = text
		label.fit_content =true	
		
		# Pastikan Label terlihat (reset alpha jadi 1)
		node.modulate.a = 1.0
		node.show()
		# Animasi fade out
		var tween := create_tween()
		tween.tween_interval(2.0)
		tween.tween_property(node, "modulate:a", 0.0, 1.0)
		return
