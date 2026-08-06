#@tool
extends Node

@export var warna_border: Color = Color.WHITE
@export var tebal_border: float = 2

# Hapus @onready untuk preload karena preload dieksekusi saat kompilasi (lebih aman untuk @tool)
var btn_templete = preload("res://Logic/object_For_skrip/button.tscn")

var daftar_wilayah: Array = []

# Dipakai HANYA kalau wilayah tidak punya data Resource sama sekali (fallback darurat)
@export var font_size_default: int = 12

enum TipeWilayah_dibuka_list  {
	PROVINSI,
	KABUPATEN,
	KECAMATAN
}
var tipe_wilayah_terbuka:TipeWilayah_dibuka_list=TipeWilayah_dibuka_list.KECAMATAN
func _ready() -> void:
	await get_tree().process_frame
	ambil_semua_wilayah()
	SaveManager.load_status_wilayah(daftar_wilayah)
	cek_syarat_buka()
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
	
	var data: Wilayah = wilayah.get("data")
	if data == null:
		return

	if data.terbuka_default:
		return
		
	var button := btn_templete.instantiate() as Button
	wilayah.add_child(button)

	var skala: float = data.skala_button if data != null else 1.0

	button.text =str(wilayah.data.harga)
	button.top_level = true
	button.clip_text = false
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", font_size_default)
	button.custom_minimum_size = Vector2.ZERO
	button.size = button.get_minimum_size()
	button.pivot_offset = button.size * 0.5
	button.scale = Vector2(skala, skala)
	button.pressed.connect(_on_skill_button_pressedd.bind(wilayah,button))

	var center_global := ambil_center_polygon_global(polygon)
	var ukuran_setelah_scale := button.size * skala
	button.global_position = center_global - ukuran_setelah_scale * 0.5


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

func cek_syarat_buka():
	if(Point.TipeWilayahArray.y>=3):
		tipe_wilayah_terbuka=TipeWilayah_dibuka_list.PROVINSI
	elif(Point.TipeWilayahArray.z>=7):
		tipe_wilayah_terbuka=TipeWilayah_dibuka_list.KABUPATEN
	Point.tipe_wilayah_terbuka = int(tipe_wilayah_terbuka)
func cek_status_tipe_wilayah(tipe):
	if tipe==0:
		Point.TipeWilayahArray.x+=1
	elif tipe==1:
		Point.TipeWilayahArray.y+=1
	else:
		Point.TipeWilayahArray.z+=1
	SaveManager.save_game()
	
func _on_skill_button_pressedd(wilayah:Node,button:Button):
	var data_wilayah: Wilayah = wilayah.data
	if  data_wilayah.harga<=Point.point:
		var tipe=data_wilayah.tipe_wilayah
		cek_status_tipe_wilayah(tipe)
		data_wilayah.terbuka_default = true
		wilayah.perbarui_tampilan()
		SaveManager.save_status_wilayah(daftar_wilayah)
		cek_syarat_buka()
		button.queue_free()
		
		var cam := get_viewport().get_camera_2d()
		if cam and cam.has_method("shake"):
			cam.shake(15.0, 0.35) # Getaran kuat saat berhasil buka wilayah baru
	
func spawn_pohon() -> void:
	var wil = daftar_wilayah.filter(func(w): return w.data and w.data.terbuka_default and w.has_node("Polygon2D"))
	if wil.is_empty(): return
	var poly = wil.pick_random().get_node("Polygon2D")
	var pts = poly.polygon; var pt = pts[0]; var rect = Rect2(pt, Vector2.ZERO)
	for p in pts: rect = rect.expand(p)
	for i in 100:
		pt = Vector2(randf_range(rect.position.x, rect.end.x), randf_range(rect.position.y, rect.end.y))
		if Geometry2D.is_point_in_polygon(pt, pts) and Geometry2D.is_point_in_polygon(pt+Vector2(3,3), pts) and Geometry2D.is_point_in_polygon(pt-Vector2(3,3), pts): break
	var pohon = preload("res://sawit.tscn").instantiate()
	pohon.position = poly.global_transform * (pt + poly.offset)
	get_parent().add_child(pohon)
	
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("shake"):
		cam.shake(5.0, 0.15) # Getaran halus saat nanam/spawn sawit
