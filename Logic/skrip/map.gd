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
	update_max_capacity_by_area()

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
			
		update_max_capacity_by_area()

func hitung_luas_polygon(titik: PackedVector2Array) -> float:
	if titik.size() < 3: return 0.0
	var luas = 0.0
	for i in range(titik.size()):
		var p0 = titik[i]
		var p1 = titik[(i + 1) % titik.size()]
		luas += p0.cross(p1)
	return absf(luas * 0.5)

func hitung_total_luas_terbuka() -> float:
	var total = 0.0
	for w in daftar_wilayah:
		if w.data and w.data.terbuka_default:
			var poly = w.get_node_or_null("Polygon2D")
			if poly:
				total += hitung_luas_polygon(poly.polygon)
	return total

func get_current_max_capacity() -> int:
	var total_luas = hitung_total_luas_terbuka()
	# Misal 1 pohon butuh 25 area lokal. (Bisa di-tweak)
	# Semakin luas, semakin banyak kapasitas pohon dan buruh.
	return max(10, int(total_luas / 1.0))

func update_max_capacity_by_area() -> void:
	var max_cap = get_current_max_capacity()
	
	# Cari upgrade_database, yang di-load di update_menu
	# Bisa di-broadcast via group atau langsung loop
	for u in SaveManager.read_save_data().get("upgrades", []):
		# Sayangnya kita harus mengubah Resource langsung.
		pass
	
	# Karena UpgradeDatabase dipegang oleh Ui, kita update langsung via group jika ada
	get_tree().call_group("upgrade_ui", "_on_max_capacity_changed", max_cap)

	
var _recent_spawned_positions: Array[Vector2] = []

func spawn_pohon(silent: bool = false) -> void:
	var wil = daftar_wilayah.filter(func(w): return w.data and w.data.terbuka_default and w.has_node("Polygon2D"))
	if wil.is_empty(): return
	var poly = wil.pick_random().get_node("Polygon2D")
	
	var pt = get_random_point_in_polygon(poly, "sawit", 25.0)
	
	var pohon = preload("res://Logic/object_For_skrip/sawit.tscn").instantiate()
	pohon.is_new_spawn = not silent
	pohon.position = poly.global_transform * (pt + poly.offset)
	get_parent().add_child(pohon)
	
	var cam := get_viewport().get_camera_2d()
	if not silent and cam and cam.has_method("shake"):
		cam.shake(5.0, 0.15) 

func get_random_point_in_polygon(poly: Polygon2D, group_to_avoid: String = "", min_dist: float = 25.0) -> Vector2:
	var pts = poly.polygon
	if pts.is_empty(): return Vector2.ZERO
	var pt = pts[0]
	var rect = Rect2(pt, Vector2.ZERO)
	for p in pts: rect = rect.expand(p)
	
	var nodes_to_avoid = []
	if group_to_avoid != "":
		nodes_to_avoid = get_tree().get_nodes_in_group(group_to_avoid)
		
	var poly_transform = poly.global_transform
	var poly_offset = poly.offset
	
	var fallback_pt = rect.get_center()
	var found_any = false
	
	for i in 150: # Iterasi lebih banyak untuk polygon sempit
		pt = Vector2(randf_range(rect.position.x, rect.end.x), randf_range(rect.position.y, rect.end.y))
		
		# Cek margin agar pohon tidak terlalu ke pinggir (spill out)
		# 1.2 local units = ~36 global pixels, pas untuk ukuran sprite pohon
		var m = 1.2
		var is_inside = Geometry2D.is_point_in_polygon(pt, pts) and \
						Geometry2D.is_point_in_polygon(pt + Vector2(m, 0), pts) and \
						Geometry2D.is_point_in_polygon(pt - Vector2(m, 0), pts) and \
						Geometry2D.is_point_in_polygon(pt + Vector2(0, m), pts) and \
						Geometry2D.is_point_in_polygon(pt - Vector2(0, m), pts)
						
		if is_inside:
			if not found_any:
				fallback_pt = pt
				found_any = true
				
			var terlalu_dekat = false
			var posisi_global_calon = poly_transform * (pt + poly_offset)
			
			# Cek terhadap node yang sudah ada di tree
			if nodes_to_avoid.size() > 0:
				for n in nodes_to_avoid:
					if is_instance_valid(n) and n.global_position.distance_to(posisi_global_calon) < min_dist:
						terlalu_dekat = true
						break
			
			# Cek terhadap pohon yang di-spawn di frame ini
			if not terlalu_dekat:
				for pos in _recent_spawned_positions:
					if pos.distance_to(posisi_global_calon) < min_dist:
						terlalu_dekat = true
						break
						
			if not terlalu_dekat:
				_recent_spawned_positions.append(posisi_global_calon)
				return pt
				
	# Jika 150 iterasi tidak nemu yang jaraknya jauh, fallback ke titik APAPUN yang valid di dalam polygon
	var final_global = poly_transform * (fallback_pt + poly_offset)
	_recent_spawned_positions.append(final_global)
	return fallback_pt

func spawn_buruh(silent: bool = false):
	var wil = daftar_wilayah.filter(func(w): return w.data and w.data.terbuka_default and w.has_node("Polygon2D"))
	if wil.is_empty(): return
	var poly = wil.pick_random().get_node("Polygon2D")
	
	# Buruh tidak perlu di-jarakin seketat pohon
	var pt = get_random_point_in_polygon(poly, "", 0.0)
	var buruh = preload("uid://c6vgmp5scevx6").instantiate()
	buruh.is_new_spawn = not silent
	buruh.position = poly.global_transform * (pt + poly.offset)
	get_parent().add_child(buruh)
	var cam := get_viewport().get_camera_2d()
	if not silent and cam and cam.has_method("shake"):
		cam.shake(5.0, 0.15) 
