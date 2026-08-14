extends Control

@onready var label: Label = $PanelContainer/MarginContainer/Label

func _ready() -> void:
	add_to_group("hint_display")
	visible = false

func tampil(text: String) -> void:
	label.text = text
	visible = true
	modulate.a = 1.0

	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func(): visible = false)
