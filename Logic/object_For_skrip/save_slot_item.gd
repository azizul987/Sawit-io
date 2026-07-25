extends PanelContainer

signal load_requested
signal delete_requested

@onready var label = $Label          # sesuaikan path node Label kamu
@onready var load_button =$MarginContainer/CenterContainer/HBoxContainer/Load
@onready var delete_button = $MarginContainer/CenterContainer/HBoxContainer/Delete

func _ready():
	load_button.pressed.connect(func(): load_requested.emit())
	delete_button.pressed.connect(func(): delete_requested.emit())

func set_slot_number(slot_num: int):
	label.text = "Slot " + str(slot_num)
