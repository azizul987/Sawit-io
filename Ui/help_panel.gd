extends Control

func _ready() -> void:
	visible = false

func toggle() -> void:
	visible = not visible

func _input(event: InputEvent) -> void:
	if not visible:
		return
	# Tutup kalau klik di luar panel atau tekan Escape
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		visible = false
		get_viewport().set_input_as_handled()
