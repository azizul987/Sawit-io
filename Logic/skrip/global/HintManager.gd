extends Node

var _waiting_for_dismiss := false

# Panggil ini dari mana saja untuk tampilkan hint sekali
func show_hint(id: String, text: String) -> void:
	var data := SaveManager.read_save_data()
	var hints_shown: Dictionary = data.get("hints_shown", {})
	if hints_shown.get(id, false):
		return
	hints_shown[id] = true
	data["hints_shown"] = hints_shown
	SaveManager.write_save_data(data)
	_display(text)

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
		label.fit_content = true

		node.process_mode = Node.PROCESS_MODE_ALWAYS
		node.modulate.a = 1.0
		node.show()
	SaveManager.save_game()

	# overlay gelap juga harus ditampilkan, kalau nggak dia gak bisa nerima klik
	for overlay in get_tree().get_nodes_in_group("hint_dim_overlay"):
		overlay.process_mode = Node.PROCESS_MODE_ALWAYS
		overlay.color.a = 0.475 # Reset alpha (bug fix)
		overlay.show()

	get_tree().paused = true
	_waiting_for_dismiss = true

func dismiss_hint() -> void:
	if not _waiting_for_dismiss:
		return
	_waiting_for_dismiss = false

	var nodes := get_tree().get_nodes_in_group("hint_display")
	for node in nodes:
		var tween := create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(node, "modulate:a", 0.0, 0.3)
		tween.tween_callback(node.hide)

	for overlay in get_tree().get_nodes_in_group("hint_dim_overlay"):
		var tween := create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(overlay, "color:a", 0.0, 0.3)
		tween.tween_callback(overlay.hide)

	get_tree().paused = false
