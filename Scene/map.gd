#@tool
extends Node

@export var warna_border: Color = Color.WHITE
@export var tebal_border: float = 1
@onready var btn_templete: Button
@export var ukuran_button: Vector2 = Vector2(8, 2)
var daftar_wilayah: Array = []


@export var rasio_lebar_button: float = 0.35
@export var rasio_tinggi_button: float = 0.18

@export var ukuran_button_min: Vector2 = Vector2(8, 4)
@export var ukuran_button_max: Vector2 = Vector2(60, 18)

func _ready() -> void:
	await get_tree().process_frame

	ambil_semua_wilayah()
	perbarui_semua_border()
	buat_semua_button_wilayah()


func ambil_semua_wilayah() -> void:
	daftar_wilayah = get_tree().get_nodes_in_group("wilayah")

	print("Jumlah wilayah: ", daftar_wilayah.size())


func perbarui_semua_border() -> void:
	for wilayah in daftar_wilayah:
		perbarui_border_wilayah(wilayah)

func perbarui_border_wilayah(wilayah: Node) -> void:
	var polygon := wilayah.get_node_or_null("Polygon2D") as Polygon2D
	var border := wilayah.get_node_or_null("Line2D") as Line2D
	if polygon == null or border == null:
		return
	var titik := polygon.polygon
	if titik.size() < 2:
		return

	border.top_level = true
	border.clear_points()
	border.position = Vector2.ZERO
	border.rotation = 0.0
	border.scale = Vector2.ONE

	for p in titik:
		border.add_point(polygon.global_transform * (p + polygon.offset))
	border.add_point(polygon.global_transform * (titik[0] + polygon.offset))

	border.default_color = warna_border
	border.width = tebal_border
	border.joint_mode = Line2D.LINE_JOINT_ROUND
	border.begin_cap_mode = Line2D.LINE_CAP_ROUND
	border.end_cap_mode = Line2D.LINE_CAP_ROUND
	border.antialiased = true
	border.z_index = polygon.z_index + 1

func buat_semua_button_wilayah() -> void:
	for wilayah in daftar_wilayah:
		buat_button_wilayah(wilayah)


func buat_button_wilayah(wilayah: Node) -> void:
	var polygon := wilayah.get_node_or_null("Polygon2D") as Polygon2D

	if polygon == null:
		return

	var button := wilayah.get_node_or_null("ButtonWilayah") as Button

	if button == null:
		button = Button.new()
		button.name = "ButtonWilayah"
		wilayah.add_child(button)

		button.pressed.connect(
			func():
				print("Button wilayah diklik: ", wilayah.name)
		)

	var ukuran_otomatis := hitung_ukuran_button_dari_polygon(polygon)

	button.text = ambil_nama_wilayah(wilayah)
	button.size = ukuran_otomatis
	button.custom_minimum_size = ukuran_otomatis
	button.top_level = true
	button.clip_text = true
	button.focus_mode = Control.FOCUS_NONE

	var font_size := int(clampf(ukuran_otomatis.y * 0.55, 4.0, 10.0))
	button.add_theme_font_size_override("font_size", font_size)

	var center_global := ambil_center_polygon_global(polygon)

	button.global_position = center_global - button.size * 0.5

func ambil_nama_wilayah(wilayah: Node) -> String:
	var data = wilayah.get("data")

	if data == null:
		return wilayah.name

	var nama = data.get("nama_wilayah")

	if nama == null or nama == "":
		return wilayah.name

	return str(nama)

func ambil_center_polygon_global(polygon: Polygon2D) -> Vector2:
	var titik := polygon.polygon

	if titik.is_empty():
		return polygon.global_position

	var luas: float = 0.0
	var cx: float = 0.0
	var cy: float = 0.0

	for i in range(titik.size()):
		var p0: Vector2 = titik[i] + polygon.offset
		var p1: Vector2 = titik[(i + 1) % titik.size()] + polygon.offset

		var cross: float = p0.cross(p1)

		luas += cross
		cx += (p0.x + p1.x) * cross
		cy += (p0.y + p1.y) * cross

	luas *= 0.5

	if absf(luas) < 0.001:
		return ambil_rata_rata_polygon_global(polygon)

	cx /= 6.0 * luas
	cy /= 6.0 * luas

	var center_local := Vector2(cx, cy)

	return polygon.global_transform * center_local


func ambil_rata_rata_polygon_global(polygon: Polygon2D) -> Vector2:
	var titik := polygon.polygon
	var total := Vector2.ZERO

	for p in titik:
		total += p + polygon.offset

	var center_local := total / titik.size()

	return polygon.global_transform * center_local

func hitung_ukuran_button_dari_polygon(polygon: Polygon2D) -> Vector2:
	var rect := ambil_rect_polygon_global(polygon)

	var lebar := rect.size.x * rasio_lebar_button
	var tinggi := rect.size.y * rasio_tinggi_button

	lebar = clampf(
		lebar,
		ukuran_button_min.x,
		ukuran_button_max.x
	)

	tinggi = clampf(
		tinggi,
		ukuran_button_min.y,
		ukuran_button_max.y
	)

	return Vector2(lebar, tinggi)

func ambil_rect_polygon_global(polygon: Polygon2D) -> Rect2:
	var titik := polygon.polygon

	if titik.is_empty():
		return Rect2(polygon.global_position, Vector2.ZERO)

	var posisi_awal: Vector2 = polygon.global_transform * (titik[0] + polygon.offset)

	var min_pos := posisi_awal
	var max_pos := posisi_awal

	for p in titik:
		var posisi: Vector2 = polygon.global_transform * (p + polygon.offset)

		min_pos.x = minf(min_pos.x, posisi.x)
		min_pos.y = minf(min_pos.y, posisi.y)

		max_pos.x = maxf(max_pos.x, posisi.x)
		max_pos.y = maxf(max_pos.y, posisi.y)

	return Rect2(min_pos, max_pos - min_pos)
