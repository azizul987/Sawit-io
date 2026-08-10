extends CharacterBody2D

@export var kecepatan_jalan: float = 75.0
@export var jarak_panen: float = 25.0
@export var waktu_jeda: float = 1.5
@export var kepintaran: float = 0.2 # 0.0 = jalan acak/santuy, 1.0 = selalu cari sawit paling dekat (bisa diupgrade via menu)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_new_spawn: bool = true

var target_sawit: Node2D = null
var sawit_sebelumnya: Node2D = null
var sedang_panen: bool = false

func _physics_process(delta: float) -> void:
	if sedang_panen:
		return

	# Jika belum punya target atau target hilang dari scene
	if target_sawit == null or not is_instance_valid(target_sawit):
		cari_sawit_terdekat()
		if target_sawit == null:
			sprite.stop() # Diam di tempat jika tidak ada pohon sama sekali
			return

	# Cek jarak ke pohon sawit sasaran
	var jarak := global_position.distance_to(target_sawit.global_position)

	if jarak <= jarak_panen:
		lakukan_panen()
	else:
		# Berjalan menuju sawit terdekat
		var arah := (target_sawit.global_position - global_position).normalized()
		velocity = arah * kecepatan_jalan
		move_and_slide()
		
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

	# Buat salinan daftar dan hindari memilih pohon yang baru saja dipanen (jika ada pilihan lain)
	var kandidat := semua_sawit.duplicate()
	if kandidat.size() > 1 and sawit_sebelumnya in kandidat:
		kandidat.erase(sawit_sebelumnya)

	# Mekanisme Kepintaran (Bisa di-upgrade lewat menu):
	# Jika hasil random di bawah angka kepintaran, buruh jadi cerdas & mengambil sawit terdekat.
	# Jika di atas kepintaran (masih level awal/kurang efektif), buruh memilih sawit secara ACAK!
	if randf() <= kepintaran:
		var jarak_terdekat: float = INF
		for pohon in kandidat:
			var jarak := global_position.distance_to(pohon.global_position)
			if jarak < jarak_terdekat:
				jarak_terdekat = jarak
				target_sawit = pohon
	else:
		target_sawit = kandidat[randi() % kandidat.size()]

func lakukan_panen() -> void:
	sedang_panen = true
	velocity = Vector2.ZERO
	sprite.stop()

	# Efek lompat kecil (Game Juice!) pada buruh saat mengeksekusi panen
	var tween := create_tween()
	tween.tween_property(sprite, "position:y", sprite.position.y - 8.0, 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", sprite.position.y, 0.15).set_trans(Tween.TRANS_SINE)

	# Trigger fungsi panen di sawit (sama persis seperti efek saat pemain mengeklik)
	if is_instance_valid(target_sawit) and target_sawit.has_method("panen"):
		target_sawit.panen()

	sawit_sebelumnya = target_sawit
	target_sawit = null

	# Beri jeda sebentar sebelum mencari sawit berikutnya
	await get_tree().create_timer(waktu_jeda).timeout
	sedang_panen = false
