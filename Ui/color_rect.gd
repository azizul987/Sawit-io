extends ColorRect

var _last_tap_time := 0.0
const DOUBLE_TAP_MAX_DELAY := 0.3  # detik, jarak maksimal antar tap dianggap "double"

func _ready() -> void:
	add_to_group("hint_dim_overlay")
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()

func _on_dim_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.double_click:
			HintManager.dismiss_hint()
	elif event is InputEventScreenTouch and event.pressed:
		var now := Time.get_ticks_msec() / 1000.0
		if now - _last_tap_time <= DOUBLE_TAP_MAX_DELAY:
			HintManager.dismiss_hint()
			_last_tap_time = 0.0  # reset biar gak kepakai lagi
		else:
			_last_tap_time = now
