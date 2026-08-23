extends Node2D

enum ConfirmMode { NONE, DELETE_SLOT, DELETE_ALL }
var confirm_mode: ConfirmMode = ConfirmMode.NONE
var pending_slot_delete: int = -1
var pending_slot_ui: Control = null

const SAVE_SLOT_SCENE = preload("res://Logic/object_For_skrip/SaveSlotItem.tscn")


@onready var slot_container = $CanvasLayer/SaveMenu/ScrollContainer/MarginContainer/VBoxContainer
@onready var add_button = $CanvasLayer/SaveMenu/ScrollContainer/MarginContainer/VBoxContainer/Add
@onready var kembali_button: Button = $CanvasLayer/SaveMenu/Kembali

@onready var mulai_button: Button = $CanvasLayer/Menu_Awal/VBoxContainer/Mulai
@onready var pengaturan_button: Button = $CanvasLayer/Menu_Awal/VBoxContainer/Pengaturan
@onready var keluar_button: Button = $CanvasLayer/Menu_Awal/VBoxContainer/Keluar

@onready var settings_menu: Control = $CanvasLayer/SettingsMenu
@onready var fullscreen_btn: CheckButton = $CanvasLayer/SettingsMenu/VBoxContainer/FullscreenBtn
@onready var bgm_slider: HSlider = $CanvasLayer/SettingsMenu/VBoxContainer/BGMContainer/BGMSlider
@onready var sfx_slider: HSlider = $CanvasLayer/SettingsMenu/VBoxContainer/SFXContainer/SFXSlider
@onready var delete_save_btn: Button = $CanvasLayer/SettingsMenu/VBoxContainer/DeleteSaveBtn
@onready var settings_kembali_btn: Button = $CanvasLayer/SettingsMenu/VBoxContainer/KembaliBtn

@onready var confirm_menu: Control = $CanvasLayer/ConfirmationMenu
@onready var confirm_batal_btn: Button = $CanvasLayer/ConfirmationMenu/VBoxContainer/HBoxContainer/BatalBtn
@onready var confirm_hapus_btn: Button = $CanvasLayer/ConfirmationMenu/VBoxContainer/HBoxContainer/YaHapusBtn
@onready var confirm_label: Label = $CanvasLayer/ConfirmationMenu/VBoxContainer/ConfirmLabel

@onready var empty_hint: Label = $CanvasLayer/SaveMenu/ScrollContainer/MarginContainer/VBoxContainer/EmptyHint

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if confirm_menu.visible:
			_on_confirm_batal()
		elif settings_menu.visible:
			_on_settings_kembali_pressed()
		elif $CanvasLayer/SaveMenu.visible:
			_on_kembali_pressed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Main menu tidak boleh menjalankan autosave gameplay.
	SaveManager.set_autosave_enabled(false)
	AudioManager.play_bgm(preload("res://Asset/Audio/music/Oh My! Beautiful Moon.mp3"))
	
	show_menu_awal()
	add_button.pressed.connect(_on_add_button_pressed)
	pengaturan_button.pressed.connect(_on_pengaturan_pressed)
	keluar_button.pressed.connect(_on_keluar_pressed)
	
	fullscreen_btn.toggled.connect(_on_fullscreen_toggled)
	bgm_slider.value_changed.connect(_on_bgm_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	delete_save_btn.pressed.connect(_on_delete_save_pressed)
	settings_kembali_btn.pressed.connect(_on_settings_kembali_pressed)
	
	fullscreen_btn.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	bgm_slider.value = AudioManager.bgm_volume_linear
	sfx_slider.value = AudioManager.sfx_volume_linear
	
	_refresh_slots()
	$CanvasLayer/SaveMenu.hide()
	settings_menu.hide()
	
	confirm_batal_btn.pressed.connect(_on_confirm_batal)
	confirm_hapus_btn.pressed.connect(_on_confirm_hapus)
	confirm_menu.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_menu_awal():
	$CanvasLayer/Menu_Awal.visible = true
	$AnimationPlayer.play("menu_show")

func hide_menu_awal():
	_animate_button_click(mulai_button)
	$AnimationPlayer.play("menu_hide")
	await $AnimationPlayer.animation_finished
	$CanvasLayer/Menu_Awal.hide()
	$CanvasLayer/SaveMenu.modulate = Color(1, 1, 1, 0)
	$CanvasLayer/SaveMenu.show()
	$AnimationPlayer.play("save_show")

func _on_pengaturan_pressed() -> void:
	_animate_button_click(pengaturan_button)
	$AnimationPlayer.play("menu_hide")
	await $AnimationPlayer.animation_finished
	$CanvasLayer/Menu_Awal.hide()
	
	settings_menu.modulate = Color(1, 1, 1, 0)
	settings_menu.show()
	var tween = create_tween()
	tween.tween_property(settings_menu, "modulate", Color(1, 1, 1, 1), 0.3)

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_bgm_slider_changed(value: float) -> void:
	AudioManager.set_bgm_volume(value)

func _on_sfx_slider_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)

func _on_delete_save_pressed() -> void:
	_animate_button_click(delete_save_btn)
	confirm_mode = ConfirmMode.DELETE_ALL
	confirm_label.text = "Hapus SEMUA data save?\nIni tidak bisa dibatalkan!"
	_show_confirm_menu()

func _on_settings_kembali_pressed() -> void:
	_animate_button_click(settings_kembali_btn)
	var tween = create_tween()
	tween.tween_property(settings_menu, "modulate", Color(1, 1, 1, 0), 0.3)
	await tween.finished
	settings_menu.hide()
	show_menu_awal()

func _on_keluar_pressed() -> void:
	_animate_button_click(keluar_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()

func _refresh_slots(animated_slot: int = -1) -> void:
	for child in slot_container.get_children():
		if child == add_button or child == empty_hint:
			continue
		slot_container.remove_child(child)
		child.queue_free()

	for slot_num in SaveManager.get_all_used_slots():
		_create_slot_ui(slot_num, slot_num == animated_slot)
	
	add_button.visible = len(SaveManager.get_all_used_slots())<5
	empty_hint.visible = SaveManager.get_all_used_slots().is_empty()
	
	# Pindahkan tombol Add ke posisi paling bawah.
	slot_container.move_child(
		add_button,
		slot_container.get_child_count() - 1
	)

func _create_slot_ui(slot_num: int, animate: bool = false):
	var slot_ui = SAVE_SLOT_SCENE.instantiate()
	slot_container.add_child(slot_ui)
	slot_ui.set_slot_number(slot_num)
	slot_ui.set_slot_name(SaveManager.get_slot_name(slot_num))   # <-- BARU, load nama tersimpan
	slot_ui.load_requested.connect(_on_slot_load.bind(slot_num))
	slot_ui.delete_requested.connect(_on_slot_delete.bind(slot_num, slot_ui))
	slot_ui.slot_renamed.connect(_on_slot_renamed.bind(slot_num))   # <-- BARU
	
	if animate:
		slot_ui.modulate = Color(1, 1, 1, 0)
		slot_ui.scale = Vector2(0.3, 0.3)
		slot_ui.pivot_offset = slot_ui.custom_minimum_size / 2.0
		var tween = create_tween().set_parallel(true)
		tween.tween_property(slot_ui, "modulate", Color(1, 1, 1, 1), 0.35)
		tween.tween_property(slot_ui, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_add_button_pressed():
	_animate_button_click(add_button)
	var new_slot := SaveManager.get_next_available_slot()
	SaveManager.create_new_slot(new_slot)
	_refresh_slots(new_slot)

func _on_slot_load(slot_num: int):
	SaveManager.set_slot(slot_num)
	SaveManager.load_game()
	SaveManager.set_autosave_enabled(true)
	get_tree().change_scene_to_file("res://Scene/main.tscn")  

func _on_slot_delete(slot_num: int, slot_ui: Control):
	for btn in slot_ui.find_children("", "Button", true, false):
		btn.disabled = true
	pending_slot_delete = slot_num
	pending_slot_ui = slot_ui
	confirm_mode = ConfirmMode.DELETE_SLOT
	confirm_label.text = "Hapus Slot " + str(slot_num) + "?"
	_show_confirm_menu()

func _show_confirm_menu():
	confirm_menu.modulate = Color(1, 1, 1, 0)
	confirm_menu.show()
	var tween = create_tween()
	tween.tween_property(confirm_menu, "modulate", Color(1, 1, 1, 1), 0.2)

func _hide_confirm_menu():
	var tween = create_tween()
	tween.tween_property(confirm_menu, "modulate", Color(1, 1, 1, 0), 0.2)
	await tween.finished
	confirm_menu.hide()

func _on_confirm_batal():
	_animate_button_click(confirm_batal_btn)
	if confirm_mode == ConfirmMode.DELETE_SLOT and is_instance_valid(pending_slot_ui):
		for btn in pending_slot_ui.find_children("", "Button", true, false):
			btn.disabled = false
	confirm_mode = ConfirmMode.NONE
	_hide_confirm_menu()

func _on_confirm_hapus():
	_animate_button_click(confirm_hapus_btn)
	var mode = confirm_mode
	confirm_mode = ConfirmMode.NONE
	
	if mode == ConfirmMode.DELETE_ALL:
		SaveManager.delete_all_saves()
		_refresh_slots()
		_hide_confirm_menu()
		_on_settings_kembali_pressed()
	elif mode == ConfirmMode.DELETE_SLOT:
		var slot_num = pending_slot_delete
		var slot_ui = pending_slot_ui
		_hide_confirm_menu()
		
		if not is_instance_valid(slot_ui):
			return
			
		slot_ui.pivot_offset = slot_ui.custom_minimum_size / 2.0
		var tween = create_tween().set_parallel(true)
		tween.tween_property(slot_ui, "modulate", Color(1, 0.2, 0.2, 0.0), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(slot_ui, "scale", Vector2(0.1, 0.1), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await tween.finished
		
		if not is_inside_tree():
			return
			
		SaveManager.delete_slot(slot_num)
		_refresh_slots()
		

func _on_kembali_pressed() -> void:
	_animate_button_click(kembali_button)
	$AnimationPlayer.play("save_hide")
	await $AnimationPlayer.animation_finished
	$CanvasLayer/SaveMenu.hide()
	show_menu_awal()

func _animate_button_click(btn: Button) -> void:
	if not is_instance_valid(btn):
		return
	
	AudioManager.play_sfx()
	
	btn.pivot_offset = btn.size / 2.0
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.07)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

func _on_slot_renamed(new_name: String, slot_num: int):
	SaveManager.set_slot_name(slot_num, new_name)
