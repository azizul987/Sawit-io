extends Area2D

@onready var sprite2d = $AnimatedSprite2D

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Point.add_point(Point.point_per_click)
		goyang_pohon()

func goyang_pohon():
	var tween = create_tween()
	tween.tween_property(sprite2d, "scale", Vector2(1.2, 0.8), 0.05)
	tween.tween_property(sprite2d, "scale", Vector2(1.0, 1.0), 0.1)

