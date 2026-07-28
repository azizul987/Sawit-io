#@tool
extends Area2D


signal wilayah_diklik(wilayah)
signal wilayah_terkunci(wilayah)

const FONT_KOSTUM = preload(
	"res://temp tekture/font/BPdotsSquareBold.otf"
)

@export var data: Wilayah

var can_click: bool = true
var is_hovering: bool = false

@onready var polygon: Polygon2D = $Polygon2D


@export var warna_border: Color = Color.BLACK
#@export var tebal_border: float = 2.0

func _ready() -> void:
	add_to_group("wilayah")

	input_pickable = true

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	perbarui_tampilan()
	#perbarui_border()


func sudah_terbuka() -> bool:
	if data == null:
		return false

	return data.terbuka_default


func perbarui_tampilan() -> void:
	if polygon == null or data == null:
		return

	if sudah_terbuka():
		polygon.color = data.warna_terbuka
	else:
		polygon.color = data.warna_terkunci


func _input_event(
	_viewport: Viewport,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if data == null:
		return

	if not event is InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if not event.pressed:
		return

	wilayah_diklik.emit(self)

	if not sudah_terbuka():
		wilayah_terkunci.emit(self)

		print(
			data.nama_wilayah,
			" masih terkunci. Harga: ",
			data.harga
		)

		return

	Point.add_point(Point.point_per_click)
	show_plus_effect(Point.point_per_click)


func _on_mouse_entered() -> void:
	is_hovering = true
	update_kursor()


func _on_mouse_exited() -> void:
	is_hovering = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func update_kursor() -> void:
	if not is_hovering:
		return

	if not sudah_terbuka():
		Input.set_default_cursor_shape(Input.CURSOR_FORBIDDEN)
	elif can_click:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_WAIT)


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
