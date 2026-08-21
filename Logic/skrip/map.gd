#@tool
extends Node2D

@export var warna_border: Color = Color.WHITE
@export var tebal_border: float = 2

# Hapus @onready untuk preload karena preload dieksekusi saat kompilasi (lebih aman untuk @tool)
var btn_templete = preload("res://Logic/object_For_skrip/button.tscn")

var daftar_wilayah: Array = []

# Dipakai HANYA kalau wilayah tidak punya data Resource sama sek-ali (fallback darurat)
@export var font_size_default: int = 12

enum TipeWilayah_dibuka_list  {
	PROVINSI,
	KABUPATEN,
	KECAMATAN
}
var tipe_wilayah_terbuka:TipeWilayah_dibuka_list=TipeWilayah_dibuka_list.KECAMATAN

func _ready() -> void:
	z_index = -1
	await get_tree().process_frame
	tipe_wilayah_terbuka = Point.tipe_wilayah_terbuka as TipeWilayah_dibuka_list
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
		
	# Sembunyikan button jika tingkatannya (enum) tidak sesuai dengan settingan kamera/zoom saat ini
	if data.tipe_wilayah != Point.tipe_wilayah_terbuka:
		if data.tipe_wilayah == 0 and Point.tipe_wilayah_terbuka !=0:
			polygon.color=Color(0.0, 0.0, 0.0, 1)
		return
		
	var button := btn_templete.instantiate() as Button
	wilayah.add_child(button)

	var skala: float = data.skala_button if data != null else 1.0

	button.text = Point.format_num(float(wilayah.data.harga))
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
	get_tree().call_group("upgrade_ui", "generate_upgrade_buttons")

func eksekusi_naik_tingkat(tipe_baru: int):
	var old_tipe = tipe_wilayah_terbuka
	tipe_wilayah_terbuka = tipe_baru as TipeWilayah_dibuka_list
	Point.tipe_wilayah_terbuka = tipe_baru
	buat_semua_button_wilayah()
	refresh_visual_sprites(old_tipe, tipe_baru)
	update_max_capacity_by_area()

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
		
		BalanceLogger.log_wilayah_purchase(data_wilayah, data_wilayah.harga)
		
		var cam := get_viewport().get_camera_2d()
		if cam and cam.has_method("shake"):
			cam.shake(15.0, 0.35) # Getaran kuat saat berhasil buka wilayah baru
			
		update_max_capacity_by_area()

func hitung_luas_polygon(poly: Polygon2D) -> float:
	var titik = poly.polygon
	if titik.size() < 3: return 0.0
	var luas = 0.0
	for i in range(titik.size()):
		var p0 = titik[i]
		var p1 = titik[(i + 1) % titik.size()]
		luas += p0.cross(p1)
	
	# Ambil nilai skala global untuk menghitung luas sesungguhnya di layar
	var scale = poly.global_scale
	return absf(luas * 0.5) * scale.x * scale.y

func hitung_total_luas_terbuka() -> float:
	var total = 0.0
	for w in daftar_wilayah:
		if w.data and w.data.terbuka_default:
			var poly = w.get_node_or_null("Polygon2D")
			if poly:
				total += hitung_luas_polygon(poly)
	return total

func get_current_max_capacity() -> int:
	var total_cap = 0
	var area_per_tree = 2800.0 * get_area_multiplier(Point.tipe_wilayah_terbuka)
	for w in daftar_wilayah:
		if w.data and w.data.terbuka_default:
			var poly = w.get_node_or_null("Polygon2D")
			if poly:
				var luas = hitung_luas_polygon(poly)
				total_cap += max(1, int(luas / area_per_tree))
	return max(10, total_cap)

func get_current_max_capacity_buruh() -> int:
	var total_cap=0
	var area_perburuh=6000*get_area_multiplier(Point.tipe_wilayah_terbuka)
	for w in daftar_wilayah:
		if w.data and w.data.terbuka_default:
			var poly=w.get_node_or_null("Polygon2D")
			if poly:
				var luas = hitung_luas_polygon(poly)
				total_cap += max(1, int(luas / area_perburuh))
	return max(10, total_cap)
	
func update_max_capacity_by_area() -> void:
	var max_cap = get_current_max_capacity()
	var max_cap_buruh = get_current_max_capacity_buruh()
	
	# Cari upgrade_database, yang di-load di update_menu
	for u in SaveManager.read_save_data().get("upgrades", []):
		pass
	
	get_tree().call_group(
	"upgrade_ui",
	"_on_max_capacity_changed_multi",
	max_cap,
	max_cap_buruh,
	get_total_bonus_upgrade()	
)

	
var _recent_spawned_positions: Array[Vector2] = []
var _pohon_per_wilayah: Dictionary = {}
var _buruh_per_wilayah: Dictionary = {}

func refresh_visual_sprites(old_tipe: int, new_tipe: int):
	# Hapus semua sprite visual
	for p in get_tree().get_nodes_in_group("sawit_visual"): p.queue_free()
	for b in get_tree().get_nodes_in_group("buruh_visual"): b.queue_free()
	_pohon_per_wilayah.clear()
	_buruh_per_wilayah.clear()
	_recent_spawned_positions.clear()
	
	# Jalankan kompresi level upgrade agar harga menjadi murah kembali
	compress_upgrades(old_tipe, new_tipe)
	
	# Panggil update_menu untuk spawn ulang sesuai level baru yang sudah dikompres
	get_tree().call_group("upgrade_ui", "sync_visuals")

func get_area_multiplier(tipe: int) -> float:
	if tipe == 1: return 6.25
	if tipe == 0: return 25.0
	return 1.0

func compress_upgrades(old_tipe: int, new_tipe: int):
	var ui = get_tree().get_first_node_in_group("upgrade_ui")
	if not ui or not ui.get("upgrade_database"): return
	
	var db = ui.upgrade_database
	var pristine_db = ResourceLoader.load(db.resource_path, "", ResourceLoader.CACHE_MODE_IGNORE) as UpgradeDatabase
	
	var div = get_area_multiplier(new_tipe) / get_area_multiplier(old_tipe)
	if div <= 1.0: return
	
	for i in db.upgrades.size():
		var up = db.upgrades[i]
		if not up: continue
		if up.upgrade_name == "Jumlah Sawit" or up.upgrade_name == "Pohon Sawit" or up.upgrade_name == "Rekrut":
			var harga_lama = up.price          # <- simpan harga NYATA sebelum apapun diubah
			var old_level = up.current_level
			
			up.current_level = int(old_level / div)
			up.price = ceil(harga_lama * div)  # <- turunan dari harga real, bukan rekonstruksi rumus
			up.effect_value = pristine_db.upgrades[i].effect_value * get_area_multiplier(new_tipe)
	
	SaveManager.save_upgrades(db)
	Point.recalculate_stats(db.upgrades)

func get_kapasitas_wilayah(poly: Polygon2D) -> int:
	var luas = hitung_luas_polygon(poly)
	# Menggunakan 2800 sebagai base kompromi
	var area_per_tree = 2800.0 * get_area_multiplier(Point.tipe_wilayah_terbuka)
	return max(1, int(luas / area_per_tree))

func pick_weighted_wilayah(is_pohon: bool) -> Polygon2D:
	var wil_terbuka = daftar_wilayah.filter(func(w): return w.data and w.data.terbuka_default and w.has_node("Polygon2D"))
	if wil_terbuka.is_empty(): return null
	
	var weights = []
	var total_weight = 0.0
	
	for w in wil_terbuka:
		var poly = w.get_node("Polygon2D")
		var cap = 0
		var current = 0
		if is_pohon:
			cap = get_kapasitas_wilayah(poly)
			current = _pohon_per_wilayah.get(w, 0)
		else:
			cap = 15
			current = _buruh_per_wilayah.get(w, 0)
			
		var rem = cap - current
		if rem < 0: rem = 0
		
		# Jika sisa kapasitas 0 (penuh), kasih bobot super kecil agar wilayah yang masih kosong 
		# jauh lebih diprioritaskan, namun mencegah game stuck jika *semua* wilayah penuh.
		var w_val = float(max(rem, 0.1))
		weights.append({ "poly": poly, "wil": w, "w": w_val })
		total_weight += w_val
		
	var r = randf() * total_weight
	var acc = 0.0
	for item in weights:
		acc += item["w"]
		if r <= acc:
			if is_pohon:
				_pohon_per_wilayah[item["wil"]] = _pohon_per_wilayah.get(item["wil"], 0) + 1
			else:
				_buruh_per_wilayah[item["wil"]] = _buruh_per_wilayah.get(item["wil"], 0) + 1
			return item["poly"]
			
	var fallback_item = weights.pick_random()
	if is_pohon:
		_pohon_per_wilayah[fallback_item["wil"]] = _pohon_per_wilayah.get(fallback_item["wil"], 0) + 1
	else:
		_buruh_per_wilayah[fallback_item["wil"]] = _buruh_per_wilayah.get(fallback_item["wil"], 0) + 1
	return fallback_item["poly"]

func spawn_pohon(silent: bool = false) -> void:
	var poly = pick_weighted_wilayah(true)
	if poly == null: return
	
	var scale_factor = 2.01
	if Point.tipe_wilayah_terbuka == 1:
		scale_factor = 7
	elif Point.tipe_wilayah_terbuka == 0:
		scale_factor = 14.0
	
	# Jarak asli 25.0 itu disetel saat skala pohon 2.0, jadi kita kalikan rasio skalanya
	var pt = get_random_point_in_polygon(poly, "sawit", 25.0 * (scale_factor / 2.0))
	
	var pohon = preload("res://Logic/object_For_skrip/sawit.tscn").instantiate()
	pohon.is_new_spawn = not silent
	pohon.position = poly.global_transform * (pt + poly.offset)
	pohon.add_to_group("sawit_visual")
	
	pohon.scale = Vector2(scale_factor, scale_factor)
		
	get_parent().add_child(pohon)
	
	var cam := get_viewport().get_camera_2d()
	if not silent and cam and cam.has_method("shake"):
		cam.shake(5.0, 0.15)
		AudioManager.play_sfx()
	

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
		
		# Kurangi margin menjadi sangat tipis agar pohon di pinggir batas wilayah bisa menempel
		# dan bersatu dengan pohon di wilayah sebelahnya (menghilangkan garis kosong)
		var m = 0.2
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
	var poly = pick_weighted_wilayah(false)
	if poly == null: return
	
	var scale_factor = 2.01
	if Point.tipe_wilayah_terbuka == 1:
		scale_factor = 7.0
	elif Point.tipe_wilayah_terbuka == 0:
		scale_factor = 14.0
	
	# Buruh tidak perlu di-jarakin seketat pohon
	var pt = get_random_point_in_polygon(poly, "", 0.0)
	var buruh = preload("uid://c6vgmp5scevx6").instantiate()
	buruh.is_new_spawn = not silent
	buruh.position = poly.global_transform * (pt + poly.offset)
	buruh.add_to_group("buruh_visual")
	
	buruh.scale = Vector2(scale_factor, scale_factor)
		
	get_parent().add_child(buruh)
	var cam := get_viewport().get_camera_2d()
	if not silent and cam and cam.has_method("shake"):
		cam.shake(5.0, 0.15)
		
func get_total_bonus_upgrade() -> int:
	var total_bonus = 0
	for w in daftar_wilayah:
		if w.data and w.data.terbuka_default:
			total_bonus += 50 # Misalnya tiap wilayah menambah max level 50
	return total_bonus
