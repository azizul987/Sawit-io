extends Control

@onready var panel: PanelContainer = $CenterContainer/PanelContainer
@onready var resume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Resume
@onready var save_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Save
@onready var main_menu_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MainMenu

func _ready() -> void:
	# Sembunyikan menu saat awal game berjalan
	hide()
	
	# Hubungkan sinyal klik tombol
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func _input(event: InputEvent) -> void:
	# Tekan ESC atau tombol Back untuk membuka/menutup Pause Menu
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		# Jangan jalankan pause jika sedang berada di MainMenu
		if get_tree().current_scene and get_tree().current_scene.name == "MainMenu":
			return
			
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	var will_pause = not get_tree().paused
	get_tree().paused = will_pause
	visible = will_pause
	
	if will_pause:
		_animate_open()

func _animate_open() -> void:
	panel.pivot_offset = panel.custom_minimum_size / 2.0
	panel.scale = Vector2(0.7, 0.7)
	panel.modulate = Color(1, 1, 1, 0)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.2)

func _on_resume_pressed() -> void:
	_animate_button_click(resume_button)
	await get_tree().create_timer(0.15, true).timeout
	get_tree().paused = false
	hide()

func _on_save_pressed() -> void:
	_animate_button_click(save_button)
	SaveManager.save_game()
	
	# Ubah teks tombol sementara agar pemain tahu data sukses tersimpan
	var old_text = "Simpan Game"
	save_button.text = "Tersimpan!"
	save_button.disabled = true
	
	await get_tree().create_timer(1.0, true).timeout
	if is_instance_valid(save_button):
		save_button.text = old_text
		save_button.disabled = false

func _on_main_menu_pressed() -> void:
	_animate_button_click(main_menu_button)
	await get_tree().create_timer(0.15, true).timeout
	
	# Simpan otomatis dan lepas status pause sebelum ganti scene ke menu utama
	SaveManager.save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/MainMenui.tscn")

func _animate_button_click(btn: Button) -> void:
	btn.pivot_offset = btn.size / 2.0
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.07)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
