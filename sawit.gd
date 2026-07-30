extends Area2D

@onready var sprite2d = $AnimatedSprite2D

const FONT_KOSTUM = preload(
	"res://temp tekture/font/BPdotsSquareBold.otf"
)

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Point.add_point(Point.point_per_click)
		goyang_pohon()
		show_plus_effect(Point.point_per_click)

func goyang_pohon():
	var tween = create_tween()
	tween.tween_property(sprite2d, "scale", Vector2(1.2, 0.8), 0.05)
	tween.tween_property(sprite2d, "scale", Vector2(1.0, 1.0), 0.1)

func show_plus_effect(jumlah_poin: float) -> void:
	var label := Label.new()

	label.text = "+%.1f" % jumlah_poin
	label.z_index = 100
	label.modulate = Color.from_hsv(
		randf_range(0.22, 0.45), # hijau kekuningan sampai hijau kebiruan
		randf_range(0.45, 1.0),  # kepekatan warna
		randf_range(0.55, 1.0),  # terang-gelap
		1.0
	)
	label.rotation = deg_to_rad(randf_range(-15.0, 15.0))
	label.add_theme_font_override("font", FONT_KOSTUM)
	label.add_theme_font_size_override("font_size", randi_range(20,50))

	var z: float = 1.0 / get_viewport().get_camera_2d().zoom.x
	label.scale = Vector2(z, z)

	get_tree().current_scene.add_child(label)

	label.global_position = get_global_mouse_position() + Vector2(randf_range(-15, 15), randf_range(-10, 5)) * z
	var arah_gerak := Vector2(
	randf_range(-35.0, 35.0),
	randf_range(-80.0, -40.0)
) * z

	var durasi: float = randf_range(0.4, 0.9)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
	label,
	"global_position",
	label.global_position + arah_gerak,
	durasi
)

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		durasi
	)

	tween.tween_property(
		label,
		"scale",
		label.scale * randf_range(1.1, 1.5),
		durasi
	)

	await tween.finished
	label.queue_free()
