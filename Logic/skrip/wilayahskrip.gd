#@tool
extends Area2D


signal wilayah_diklik(wilayah)
signal wilayah_terkunci(wilayah)


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
	if data == null:
		return

	var warna: Color = data.warna_terbuka if sudah_terbuka() else data.warna_terkunci
	
	# Warnai SEMUA Polygon2D di dalam wilayah ini (mendukung wilayah dengan >1 polygon/pulau)
	for child in get_children():
		if child is Polygon2D:
			child.color = warna


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

		#print(
			#data.nama_wilayah,
			#" masih terkunci. Harga: ",
			#data.harga
		#)

		return

	#Point.add_point(Point.point_per_click)
	#show_plus_effect(Point.point_per_click)


func _on_mouse_entered() -> void:
	#is_hovering = true
	#update_kursor()
	pass

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
