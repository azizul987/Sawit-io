extends Node

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

	var labels := get_tree().get_nodes_in_group("hint_display")
	for label in labels:
		label.text = text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.custom_minimum_size = Vector2(300, 0)

		var tween := create_tween()
		tween.tween_interval(2.0)
		tween.tween_property(label, "modulate:a", 0.0, 1.0)
