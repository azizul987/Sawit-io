class_name Wilayah
extends Area2D

signal wilayah_diklik(wilayah: Wilayah)
signal wilayah_terkunci(wilayah: Wilayah)

const FONT_KOSTUM = preload(
	"res://temp tekture/font/BPdotsSquareBold.otf"
)

@export var data: Area

var can_click: bool = true
var is_hovering: bool = false

@onready var polygon: Polygon2D = $Polygon2D


func _ready() -> void:
	input_pickable = true

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	perbarui_tampilan()


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

	if not can_click:
		return

	can_click = false
	update_kursor()

	Point.add_point(Point.point_per_click)
	show_plus_effect(Point.point_per_click)

	await get_tree().create_timer(Point.cd).timeout

	can_click = true
	update_kursor()


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


func show_plus_effect(jumlah_poin: int) -> void:
	var label := Label.new()

	label.text = "+%.1f" % jumlah_poin
	label.z_index = 100
	label.modulate = Color.WHITE

	label.add_theme_font_override("font", FONT_KOSTUM)
	label.add_theme_font_size_override("font_size", 8)

	get_tree().current_scene.add_child(label)

	label.global_position = get_global_mouse_position()

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		label,
		"global_position",
		label.global_position + Vector2(0, -50),
		0.6
	)

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		0.6
	)

	await tween.finished
	label.queue_free()
