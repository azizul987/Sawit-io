extends Node2D

# ============================================================
# Bonus Wilayah — "Golden Cookie" style bonus click pada wilayah
# Muncul random di wilayah terbuka, diklik → kasih bonus besar
# ============================================================

@export var spawn_interval_min: float = 45.0
@export var spawn_interval_max: float = 90.0
@export var display_duration: float = 10.0 # detik sebelum hilang kalau gak diklik

const FONT_KOSTUM = preload(
	"res://temp tekture/font/BPdotsSquareBold.otf"
)

var _map_node: Node = null
var _spawn_timer: Timer
var _despawn_timer: Timer
var _active_bonus: Area2D = null
var _is_bonus_active: bool = false

func _ready() -> void:
	# Cari node map (parent-nya harusnya map)
	_map_node = get_parent()
	
	# Timer spawn (interval random)
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	_spawn_timer.timeout.connect(_on_spawn_timer)
	add_child(_spawn_timer)
	
	# Timer despawn (batas waktu klik)
	_despawn_timer = Timer.new()
	_despawn_timer.one_shot = true
	_despawn_timer.timeout.connect(_on_despawn_timer)
	add_child(_despawn_timer)
	
	# Mulai timer pertama
	_start_spawn_timer()


func _start_spawn_timer() -> void:
	var wait_time = randf_range(spawn_interval_min, spawn_interval_max)
	_spawn_timer.start(wait_time)


func _on_spawn_timer() -> void:
	if _is_bonus_active:
		return
	_spawn_bonus()


func _on_despawn_timer() -> void:
	_remove_bonus()
	_start_spawn_timer()


func _spawn_bonus() -> void:
	if not _map_node or not _map_node.has_method("hitung_luas_polygon"):
		_start_spawn_timer()
		return
	
	# Ambil wilayah terbuka
	var wilayah_terbuka: Array = []
	for w in _map_node.daftar_wilayah:
		if w.data and w.data.terbuka_default and w.has_node("Polygon2D"):
			wilayah_terbuka.append(w)
	
	if wilayah_terbuka.is_empty():
		_start_spawn_timer()
		return
	
	# Pilih random wilayah
	var chosen = wilayah_terbuka.pick_random()
	var poly: Polygon2D = chosen.get_node("Polygon2D")
	
	# Tentukan posisi spawn di dalam polygon
	var spawn_pos = _get_random_point_in_poly(poly)
	
	# Buat Area2D sebagai bonus clickable
	_active_bonus = Area2D.new()
	_active_bonus.position = spawn_pos
	_active_bonus.monitoring = false
	_active_bonus.monitorable = false
	_active_bonus.collision_mask = 0
	_active_bonus.input_pickable = true
	_active_bonus.z_index = 50
	_active_bonus.add_to_group("bonus_wilayah")
	
	# Collision shape
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 30.0
	col.shape = shape
	_active_bonus.add_child(col)
	
	# Sprite (pakai icon sawit emas)
	var sprite = Sprite2D.new()
	var icon_tex = load("res://Asset/Icon/BuahSawitEmasUpgrade.png")
	if icon_tex:
		sprite.texture = icon_tex
	sprite.scale = Vector2(2.5, 2.5)
	_active_bonus.add_child(sprite)
	
	# Scale sesuai tipe wilayah
	var scale_factor = 2.01
	if Point.tipe_wilayah_terbuka == 1:
		scale_factor = 7.0
	elif Point.tipe_wilayah_terbuka == 0:
		scale_factor = 14.0
	_active_bonus.scale = Vector2(scale_factor, scale_factor)
	
	# Connect input event
	_active_bonus.input_event.connect(_on_bonus_clicked)
	
	# Tambah ke scene
	get_tree().current_scene.add_child(_active_bonus)
	
	# Animasi masuk: bounce scale + fade in
	_active_bonus.modulate.a = 0.0
	_active_bonus.scale = Vector2.ZERO
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_active_bonus, "scale", Vector2(scale_factor, scale_factor), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_active_bonus, "modulate:a", 1.0, 0.3)
	
	# Animasi berkedip terus-menerus
	_start_blink_animation()
	
	_is_bonus_active = true
	_despawn_timer.start(display_duration)


func _start_blink_animation() -> void:
	if not is_instance_valid(_active_bonus):
		return
	var blink_tween = create_tween()
	blink_tween.set_loops() # Loop tak terbatas
	blink_tween.tween_property(_active_bonus, "modulate:a", 0.4, 0.5)
	blink_tween.tween_property(_active_bonus, "modulate:a", 1.0, 0.5)


func _on_bonus_clicked(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	if not _is_bonus_active:
		return
	
	# Hitung reward: max(pps*10, ppc*5), minimal 100
	var reward = max(Point.points_per_second * 10.0, Point.point_per_click * 5.0)
	reward = max(reward, 100.0)
	
	Point.add_point(reward)
	
	# Efek visual: partikel emas + label
	_show_bonus_effect(reward)
	
	# Camera shake
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("shake"):
		cam.shake(20.0, 0.45)
	
	# Hapus bonus
	_remove_bonus()
	_start_spawn_timer()


func _show_bonus_effect(jumlah: float) -> void:
	if not is_instance_valid(_active_bonus):
		return
	
	var bonus_pos = _active_bonus.global_position
	
	# Partikel emas
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.lifetime = 1.0
	particles.amount = 30
	particles.direction = Vector2(0, -1)
	particles.spread = 120.0
	particles.gravity = Vector2(0, 200.0)
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 180.0
	particles.scale_amount_min = 4.0
	particles.scale_amount_max = 10.0
	particles.color = Color(1.0, 0.85, 0.2, 0.9) # Emas
	
	get_tree().current_scene.add_child(particles)
	particles.global_position = bonus_pos
	particles.emitting = true
	
	# Label besar
	var label := Label.new()
	label.text = "BONUS! +" + Point.format_num(jumlah)
	label.z_index = 103
	label.modulate = Color(1.0, 0.85, 0.1, 1.0) # Emas terang
	label.add_theme_font_override("font", FONT_KOSTUM)
	label.add_theme_font_size_override("font_size", 80)
	
	var z: float = 1.0 / get_viewport().get_camera_2d().zoom.x
	label.scale = Vector2(z, z)
	
	get_tree().current_scene.add_child(label)
	label.global_position = bonus_pos + Vector2(randf_range(-30, 30), -50) * z
	
	var durasi: float = 1.5
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -150) * z, durasi)
	tween.tween_property(label, "modulate:a", 0.0, durasi)
	tween.tween_property(label, "scale", label.scale * 1.8, durasi)
	
	# Cleanup
	await tween.finished
	label.queue_free()
	
	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(particles):
		particles.queue_free()


func _remove_bonus() -> void:
	_despawn_timer.stop()
	_is_bonus_active = false
	
	if is_instance_valid(_active_bonus):
		# Animasi keluar: shrink + fade
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(_active_bonus, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(_active_bonus, "modulate:a", 0.0, 0.2)
		await tween.finished
		if is_instance_valid(_active_bonus):
			_active_bonus.queue_free()
		_active_bonus = null


func _get_random_point_in_poly(poly: Polygon2D) -> Vector2:
	var pts = poly.polygon
	if pts.is_empty():
		return poly.global_position
	
	var rect = Rect2(pts[0], Vector2.ZERO)
	for p in pts:
		rect = rect.expand(p)
	
	# Coba 30 kali cari titik di dalam polygon
	for i in 30:
		var pt = Vector2(
			randf_range(rect.position.x, rect.end.x),
			randf_range(rect.position.y, rect.end.y)
		)
		if Geometry2D.is_point_in_polygon(pt, pts):
			return poly.global_transform * (pt + poly.offset)
	
	# Fallback: center polygon
	var center = Vector2.ZERO
	for p in pts:
		center += p
	center /= pts.size()
	return poly.global_transform * (center + poly.offset)
