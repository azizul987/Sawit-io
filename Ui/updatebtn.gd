class_name UpgradeButton
extends Button

signal purchase_requested(
	upgrade_data: UpgradeData,
	button: UpgradeButton
)

@onready var icon_rect: TextureButton = $HBoxContainer/MarginContainer/Icon
@onready var name_label: Label =$HBoxContainer/MarginContainer2/VBoxContainer/Nama
@onready var level_label: Label =$HBoxContainer/MarginContainer2/VBoxContainer/Level
@onready var price_label: Label = $HBoxContainer/MarginContainer2/VBoxContainer/Harga

var data: UpgradeData


func _ready() -> void:
	pressed.connect(_on_pressed)


func setup(upgrade_data: UpgradeData) -> void:
	data = upgrade_data
	refresh()


func refresh() -> void:
	if data == null:
		return

	icon_rect.texture_normal = data.icon
	name_label.text = data.upgrade_name

	level_label.text = "Level %d/%d" % [
		data.current_level,
		data.max_level
	]

	if data.is_max_level():
		price_label.text = "MAX LEVEL"
		disabled = true
	else:
		price_label.text = "Harga: %.0f" % data.price
		disabled = false


func _on_pressed() -> void:
	if data == null:
		return

	purchase_requested.emit(data, self)
