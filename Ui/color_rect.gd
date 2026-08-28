extends ColorRect

func _ready() -> void:
	add_to_group("hint_dim_overlay")   # group BARU, beda dari "hint_display"
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()

func _on_dim_overlay_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) \
	or (event is InputEventScreenTouch and event.pressed):
		HintManager.dismiss_hint()
