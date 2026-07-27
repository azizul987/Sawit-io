#@tool
extends Node

@export var warna_border: Color = Color.WHITE
@export var tebal_border: float = 2

# Hapus @onready untuk preload karena preload dieksekusi saat kompilasi (lebih aman untuk @tool)
var btn_templete = preload("res://Logic/object_For_skrip/button.tscn")

var daftar_wilayah: Array = []

# Dipakai HANYA kalau wilayah tidak punya data Resource sama sekali (fallback darurat)
@export var font_size_default: int = 12


func _ready() -> void:
	await get_tree().process_frame

	ambil_semua_wilayah()
	SaveManager.load_status_wilayah(daftar_wilayah)
	buat_semua_button_wilayah()


func ambil_semua_wilayah() -> void:
	daftar_wilayah = get_tree().get_nodes_in_group("wilayah")
	#print("Jumlah wilayah: ", daftar_wilayah.size())

func buat_semua_button_wilayah() -> void:
	for wilayah in daftar_wilayah:
		buat_button_wilayah(wilayah)


func buat_button_wilayah(wilayah: Node) -> void:
	var polygon := wilayah.get_node_or_null("Polygon2D") as Polygon2D
	if polygon == null:
		return
		
	var button := btn_templete.instantiate() as Button
	wilayah.add_child(button)

	var data: Wilayah = wilayah.get("data")
	var skala: float = data.skala_button if data != null else 1.0

	button.text = ambil_nama_wilayah(wilayah)
	button.top_level = true
	button.clip_text = false
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", font_size_default)
	button.custom_minimum_size = Vector2.ZERO
	button.size = button.get_minimum_size()
	button.pivot_offset = button.size * 0.5
	button.scale = Vector2(skala, skala)
	button.pressed.connect(_on_skill_button_pressedd.bind(wilayah))

	var center_global := ambil_center_polygon_global(polygon)
	var ukuran_setelah_scale := button.size * skala
	button.global_position = center_global - ukuran_setelah_scale * 0.5

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

func _on_skill_button_pressedd(wilayah):
	var data_wilayah: Wilayah = wilayah.get("data") as Wilayah

	if data_wilayah == null:
		return

	data_wilayah.terbuka_default = true

	if wilayah.has_method("perbarui_tampilan"):
		wilayah.perbarui_tampilan()

	SaveManager.save_status_wilayah(daftar_wilayah)
