extends Node2D

@export var kecepatan_jalan_dasar: float = 75.0
@export var jarak_panen: float = 25.0
@export var waktu_jeda: float = 1.5
@export var kepintaran_dasar: float = 0.2 # 0.0 = jalan acak/santuy, 1.0 = selalu cari sawit paling dekat

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_new_spawn: bool = true

var kecepatan_jalan: float
var kepintaran: float

var target_sawit: Node2D = null
var sawit_sebelumnya: Node2D = null
var sedang_panen: bool = false

var waktu_stuck: float = 0.0
var batas_waktu_stuck: float = 2.0
var posisi_sebelumnya: Vector2 = Vector2.ZERO

func _ready() -> void:
	_terapkan_upgrade()
	Point.worker_stats_updated.connect(_terapkan_upgrade)

	posisi_sebelumnya = global_position
	var tween=create_tween()
	tween.set_parallel()
	tween.tween_property(self,"modulate:a",randf_range(0.1,0.4),1.0)

func _terapkan_upgrade() -> void:
	kecepatan_jalan = kecepatan_jalan_dasar * Point.worker_speed_mult
	kepintaran = clamp(kepintaran_dasar + Point.worker_intel_bonus, 0.0, 1.0)



func _process(delta: float) -> void:
	if sedang_panen:
		return
	if target_sawit == null or not is_instance_valid(target_sawit):
		cari_sawit_terdekat()
		if target_sawit == null:
			sprite.stop() # Diam di tempat jika tidak ada pohon sama sekali
			return

	# Cek jarak ke pohon sawit sasaran
	var jarak := global_position.distance_to(target_sawit.global_position)

	if jarak <= jarak_panen:
		lakukan_panen()
		waktu_stuck = 0.0 # Reset
	else:
		# Berjalan menuju sawit terdekat
		var arah := (target_sawit.global_position - global_position).normalized()
		global_position += arah * kecepatan_jalan * delta
		
		# --- Sistem Deteksi Nyangkut (Stuck) ---
		var jarak_gerak_sq := global_position.distance_squared_to(posisi_sebelumnya)
		# Jika bergeraknya sangat lambat (kurang dari setengah kecepatan wajar per frame)
		var batas_gerak := kecepatan_jalan * delta * 0.5
		if jarak_gerak_sq < batas_gerak * batas_gerak:
			waktu_stuck += delta
			if waktu_stuck >= batas_waktu_stuck:
				# TELEPORT! Pindahkan buruh paksa ke dekat pohon target
				global_position = target_sawit.global_position + Vector2(randf_range(-15, 15), randf_range(10, 20))
				waktu_stuck = 0.0 # Reset
		else:
			waktu_stuck = 0.0 # Reset karena jalan lancar
		
		posisi_sebelumnya = global_position
		# --------------------------------------
		
		# Animasi berjalan & balik badan menghadap ke arah jalan
		if not sprite.is_playing():
			sprite.play("default")
		if abs(arah.x) > 0.1:
			sprite.flip_h = (arah.x < 0)

func cari_sawit_terdekat() -> void:
	var semua_sawit := get_tree().get_nodes_in_group("sawit")

	if semua_sawit.is_empty():
		target_sawit = null
		return

	if semua_sawit.size() == 1:
		target_sawit = semua_sawit[0]
		return

	if randf() <= kepintaran:
		var jarak_terdekat_sq := INF
		target_sawit = null

		for pohon in semua_sawit:
			if pohon == sawit_sebelumnya:
				continue

			var jarak_sq := global_position.distance_squared_to(
				pohon.global_position
			)

			if jarak_sq < jarak_terdekat_sq:
				jarak_terdekat_sq = jarak_sq
				target_sawit = pohon

	else:
		target_sawit = semua_sawit.pick_random()

		while target_sawit == sawit_sebelumnya:
			target_sawit = semua_sawit.pick_random()

func lakukan_panen() -> void:
	sedang_panen = true
	sprite.stop()

	# Efek lompat kecil
	var tween := create_tween()
	tween.tween_property(
		sprite,
		"position:y",
		sprite.position.y - 8.0,
		0.15
	).set_trans(Tween.TRANS_SINE)

	tween.tween_property(
		sprite,
		"position:y",
		sprite.position.y,
		0.15
	).set_trans(Tween.TRANS_SINE)

	if is_instance_valid(target_sawit) and target_sawit.has_method("panen"):
		target_sawit.panen(true)

	sawit_sebelumnya = target_sawit
	target_sawit = null

	await get_tree().create_timer(waktu_jeda).timeout
	sedang_panen = false
