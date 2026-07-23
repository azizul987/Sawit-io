extends Area2D

# Tambahkan variabel penanda ini
var can_click = true 

func _ready() -> void:
	input_pickable = true

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			# Cek apakah saat ini boleh diklik
			if can_click:
				# Langsung ubah jadi false agar tidak bisa diklik beruntun
				can_click = false 
				
				Point.add_point(1)
				show_plus_effect()
				
				# Bikin timer menunggu selama nilai 'cd' di script Point (1 detik)
				await get_tree().create_timer(Point.cd).timeout
				
				# Setelah waktu habis, kembalikan true agar bisa diklik lagi
				can_click = true

func show_plus_effect():
	var label = Label.new()
	label.text = "+1"
	label.z_index = 100
	label.add_theme_font_size_override("font_size", 28)
	label.modulate = Color(1, 1, 0, 1)

	get_tree().current_scene.add_child(label)

	label.global_position = get_global_mouse_position()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -50), 0.6)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)

	await tween.finished
	label.queue_free()
