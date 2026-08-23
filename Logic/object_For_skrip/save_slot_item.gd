extends PanelContainer

signal load_requested
signal delete_requested
signal slot_renamed(new_name: String)   # diganti dari "renamed"

@onready var label = $Label
@onready var line_edit = $LineEdit
@onready var load_button = $MarginContainer/CenterContainer/HBoxContainer/Load
@onready var delete_button = $MarginContainer/CenterContainer/HBoxContainer/Delete

var slot_num: int
var is_renaming := false

func _ready():
	load_button.pressed.connect(_on_load_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	move_child(line_edit, get_child_count() - 1)
	line_edit.hide()
	line_edit.text_submitted.connect(_on_rename_submitted)
	line_edit.focus_exited.connect(_on_rename_cancel)

	label.mouse_filter = Control.MOUSE_FILTER_STOP
	label.gui_input.connect(_on_label_gui_input)
	$MarginContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
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

func set_slot_number(num: int):
	slot_num = num

func set_slot_name(display_name: String):
	label.text = display_name

# --- BAGIAN RENAME ---

func _on_label_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.double_click:
		_start_rename()

func _start_rename():
	is_renaming = true
	line_edit.text = label.text
	label.hide()
	line_edit.show()
	line_edit.grab_focus()
	line_edit.select_all()

func _on_rename_submitted(new_text: String):
	new_text = new_text.strip_edges()
	if new_text != "":
		label.text = new_text
		slot_renamed.emit(new_text)
	line_edit.release_focus()
	_finish_rename()

func _on_rename_cancel():
	if is_renaming:
		_finish_rename()

func _finish_rename():
	is_renaming = false
	line_edit.hide()
	label.show()
