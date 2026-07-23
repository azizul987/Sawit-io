extends Area2D

# Variabel bawaanmu
var can_click = true 
const FONT_KOSTUM = preload("res://temp tekture/font/BPdotsSquareBold.otf")

# Variabel BARU penanda kursor
var is_hovering = false 

func _ready() -> void:
	input_pickable = true
	
	# Menyalakan sensor deteksi mouse masuk dan keluar dari area poligon
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			if can_click:
				can_click = false 
				
				# PANGGIL DI SINI: Langsung ubah kursor jadi tanda silang (CD dimulai)
				update_kursor()
				
				Point.add_point(1)
				show_plus_effect()
				
				await get_tree().create_timer(Point.cd).timeout
				
				can_click = true
				
				# PANGGIL DI SINI: Kembalikan kursor jadi telunjuk (CD beres)
				update_kursor()
# ==========================================
# BLOK FUNGSI BARU UNTUK MENGATUR KURSOR
# ==========================================
func _on_mouse_entered():
	is_hovering = true
	update_kursor()

func _on_mouse_exited():
	is_hovering = false
	# Kembalikan ke kursor panah biasa kalau keluar peta
	Input.set_default_cursor_shape(Input.CURSOR_ARROW) 

func update_kursor():
	if is_hovering:
		if can_click:
			# Kursor Jari Telunjuk (Siap panen)
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		else:
			# Kursor Jam Pasir / Loading (Sedang CD)
			Input.set_default_cursor_shape(Input.CURSOR_WAIT)

# ==========================================
# BLOK FUNGSI EFEK VISUAL BAWAANMU
# ==========================================
func show_plus_effect():
	var label = Label.new()
	label.text = "+1"
	label.z_index = 100
	label.add_theme_font_override("font", FONT_KOSTUM)
	label.add_theme_font_size_override("font_size", 8)
	label.modulate = Color.WHITE

	get_tree().current_scene.add_child(label)

	label.global_position = get_global_mouse_position()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -50), 0.6)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)

	await tween.finished
	label.queue_free()
