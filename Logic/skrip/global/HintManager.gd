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
	# Buat CanvasLayer supaya muncul di atas semua UI
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	get_tree().root.add_child(canvas)

	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size = Vector2(300, 0)
	label.anchor_left = 0.5
	label.anchor_top = 1.0
	label.anchor_right = 0.5
	label.anchor_bottom = 1.0
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	label.offset_left = -150
	label.offset_top = -100
	label.offset_right = 150
	label.offset_bottom = -60
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	canvas.add_child(label)

	# Fade out dan hapus setelah 3 detik
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(canvas.queue_free)
