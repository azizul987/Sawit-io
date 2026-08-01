extends PanelContainer

signal load_requested
signal delete_requested

@onready var label = $Label          # sesuaikan path node Label kamu
@onready var load_button =$MarginContainer/CenterContainer/HBoxContainer/Load
@onready var delete_button = $MarginContainer/CenterContainer/HBoxContainer/Delete

func _ready():
	load_button.pressed.connect(_on_load_pressed)
	delete_button.pressed.connect(_on_delete_pressed)

func _on_load_pressed():
	_animate_button_click(load_button)
	load_requested.emit()

func _on_delete_pressed():
	_animate_button_click(delete_button)
	delete_requested.emit()

func _animate_button_click(btn: Button):
	btn.pivot_offset = btn.size / 2.0
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(0.85, 0.85), 0.07)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

func set_slot_number(slot_num: int):
	label.text = "Slot " + str(slot_num)
