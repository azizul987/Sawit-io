extends Area2D

@onready var sprite2d = $AnimatedSprite2D

var is_new_spawn: bool = true

const FONT_KOSTUM = preload(
	"res://temp tekture/font/BPdotsSquareBold.otf"
)
func _ready() -> void:
	monitoring = false
	monitorable = false
	collision_mask = 0
	input_pickable = true

	add_to_group("sawit")
	
	if not is_new_spawn:
		return
	
	# Simpan posisi akhir
	var final_position = position
	
	# Geser posisi awal ke atas secara acak (180 s/d 300 pixel) biar beda-beda
	position.y -= randf_range(180.0, 300.0)
	modulate.a = 0.0
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Tambahkan jeda waktu (delay) acak dan durasi jatuh acak
	var random_delay = randf_range(0.0, 0.25) 
	var drop_duration = randf_range(0.5, 0.85)
	
	# Animasi jatuh dan memantul (ditambah delay & durasi random)
	tween.tween_property(self, "position", final_position, drop_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(random_delay)
	# Animasi pudar perlahan menjadi jelas (fade in)
	tween.tween_property(self, "modulate:a", 1.0, drop_duration * 0.8).set_delay(random_delay)
	
	# Munculkan efek debu saat pertama kali menyentuh tanah (kira-kira 30% dari durasi jatuhnya karena EASE_OUT BOUNCE)
	await get_tree().create_timer(random_delay + (drop_duration * 0.35)).timeout
	if is_instance_valid(self):
		create_dust_effect(final_position)

func create_dust_effect(spawn_pos: Vector2) -> void:
	var dust = CPUParticles2D.new()
	dust.emitting = false
	dust.one_shot = true
	dust.explosiveness = 0.95
	dust.lifetime = 0.6
	dust.amount = 15
	dust.direction = Vector2(0, -1)
	dust.spread = 80.0
	dust.gravity = Vector2(0, 150.0)
	dust.initial_velocity_min = 40.0
	dust.initial_velocity_max = 90.0
	dust.scale_amount_min = 3.0
	dust.scale_amount_max = 8.0
	dust.color = Color(0.85, 0.85, 0.85, 0.7) # Putih asap / debu transparan
	
	# Tambahkan partikel ke scene utama supaya tidak ikut mantul dengan pohonnya
	get_tree().current_scene.add_child(dust)
	dust.global_position = spawn_pos + Vector2(0, 25) # Posisi debu di bagian akar/bawah pohon
	dust.emitting = true
	
	# Bersihkan partikel setelah selesai
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(dust):
		dust.queue_free()

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		panen(false, get_global_mouse_position())

func panen(is_magnet_harvest: bool = false, custom_pos: Vector2 = Vector2.INF) -> void:
	var point_to_add = Point.point_per_click
	var is_double = false
	
	if Point.panen_ganda_chance > 0.0:
		if randf() * 100.0 < Point.panen_ganda_chance:
			point_to_add *= 2.0
			is_double = true
			
	Point.add_point(point_to_add)
	goyang_pohon()
	
	if is_double:
		show_double_harvest_effect(point_to_add, custom_pos)
	else:
		show_plus_effect(point_to_add, custom_pos)

	if not is_magnet_harvest and Point.magnet_radius > 0.0:
		var all_sawit = get_tree().get_nodes_in_group("sawit")
		var radius_sq = Point.magnet_radius * Point.magnet_radius
		for s in all_sawit:
			if s != self and is_instance_valid(s):
				if global_position.distance_squared_to(s.global_position) <= radius_sq:
					if s.has_method("panen"):
						s.panen(true)

func goyang_pohon():
	var tween = create_tween()
	tween.tween_property(sprite2d, "scale", Vector2(1.2, 0.8), 0.05)
	tween.tween_property(sprite2d, "scale", Vector2(1.0, 1.0), 0.1)

func show_plus_effect(jumlah_poin: float, custom_pos: Vector2 = Vector2.INF) -> void:
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

	var base_pos = global_position + Vector2(0, -60)
	if custom_pos != Vector2.INF:
		base_pos = custom_pos

	label.global_position = base_pos + Vector2(randf_range(-35, 35), randf_range(-25, 10)) * z
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

func show_double_harvest_effect(jumlah_poin: float, custom_pos: Vector2 = Vector2.INF) -> void:
	var label := Label.new()

	label.text = "DOUBLE! +%.1f" % jumlah_poin
	label.z_index = 101
	label.modulate = Color.from_hsv(
		0.15, # Warna emas/kuning
		1.0,  # kepekatan warna
		1.0,  # terang-gelap
		1.0
	)
	label.rotation = deg_to_rad(randf_range(-15.0, 15.0))
	label.add_theme_font_override("font", FONT_KOSTUM)
	label.add_theme_font_size_override("font_size", randi_range(40,70)) # Lebih besar

	var z: float = 1.0 / get_viewport().get_camera_2d().zoom.x
	label.scale = Vector2(z, z)

	get_tree().current_scene.add_child(label)

	var base_pos = global_position + Vector2(0, -60)
	if custom_pos != Vector2.INF:
		base_pos = custom_pos

	label.global_position = base_pos + Vector2(randf_range(-45, 45), randf_range(-35, 5)) * z
	var arah_gerak := Vector2(
	randf_range(-35.0, 35.0),
	randf_range(-100.0, -60.0)
) * z

	var durasi: float = randf_range(0.6, 1.2)

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
		label.scale * randf_range(1.3, 1.8),
		durasi
	)

	await tween.finished
	label.queue_free()
