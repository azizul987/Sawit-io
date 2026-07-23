extends Area2D

func _ready() -> void:
	input_pickable = true

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Point.add_point(1)
