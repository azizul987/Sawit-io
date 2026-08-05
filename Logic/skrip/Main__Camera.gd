extends Camera2D

@export var move_speed := 500.0
@export var zoom_speed := 0.12
@export var batas_zoom_out: Array[float] = [0.1, 0.25, 0.5] # [0: Provinsi, 1: Kabupaten, 2: Kecamatan]
@export var max_zoom := 10.0

var is_dragging := false


func _ready() -> void:
	SaveManager.load_game()
	position = Vector2(
		Point.main_tree_camera.x,
		Point.main_tree_camera.y
	)
	zoom = Vector2(
		Point.main_tree_camera.z,
		Point.main_tree_camera.z
	)
	make_current()


func _process(delta: float) -> void:
	if Point.is_skill_tree_open:
		return
	var direction := Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if direction != Vector2.ZERO:
		position += direction.normalized() * move_speed * delta
		simpan_posisi_camera()


func _input(event: InputEvent) -> void:
	if Point.is_skill_tree_open:
		is_dragging = false
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_dragging = event.pressed
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_camera(zoom_speed)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_camera(-zoom_speed)

	if event is InputEventKey and event.pressed and not event.echo:
		if event.is_action_pressed("zoom_in"):
			zoom_camera(zoom_speed)
		if event.is_action_pressed("zoom_out"):
			zoom_camera(-zoom_speed)

	if event is InputEventMouseMotion and is_dragging:
		position -= event.relative / zoom.x
		simpan_posisi_camera()


func zoom_camera(value: float) -> void:
	# 1. Catat posisi dunia yang ada di bawah cursor SEBELUM zoom berubah
	var posisi_mouse_sebelum := get_global_mouse_position()

	# 2. Ubah nilai zoom seperti biasa
	var new_zoom := zoom.x + value
	var idx: int = clamp(Point.tipe_wilayah_terbuka, 0, batas_zoom_out.size() - 1)
	new_zoom = clamp(new_zoom, batas_zoom_out[idx], max_zoom)
	zoom = Vector2(new_zoom, new_zoom)

	# 3. Cek posisi dunia di bawah cursor SETELAH zoom berubah
	var posisi_mouse_sesudah := get_global_mouse_position()

	# 4. Geser kamera sebesar selisihnya, supaya titik yang sama tetap di bawah cursor
	position += posisi_mouse_sebelum - posisi_mouse_sesudah

	simpan_posisi_camera()


func simpan_posisi_camera() -> void:
	Point.main_tree_camera.x = position.x
	Point.main_tree_camera.y = position.y
	Point.main_tree_camera.z = zoom.x
	SaveManager.save_game()


# --- FITUR GETAR LAYAR (SCREEN SHAKE) ---
func shake(intensity: float = 8.0, duration: float = 0.25) -> void:
	var tween := create_tween()
	var step := duration / 5.0
	for i in range(5):
		var rand_offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(self, "offset", rand_offset, step)
		intensity *= 0.6 # getaran mereda secara alami
	tween.tween_property(self, "offset", Vector2.ZERO, step)

