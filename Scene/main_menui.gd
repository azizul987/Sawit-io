extends Node2D

const SAVE_SLOT_SCENE = preload("res://Logic/object_For_skrip/SaveSlotItem.tscn")

@onready var slot_container = $CanvasLayer/SaveMenu/ScrollContainer/MarginContainer/VBoxContainer
@onready var add_button = $CanvasLayer/SaveMenu/ScrollContainer/MarginContainer/VBoxContainer/Add
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_menu_awal()
	add_button.pressed.connect(_on_add_button_pressed)
	_refresh_slots()
	$CanvasLayer/SaveMenu.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func show_menu_awal():
	$CanvasLayer/Menu_Awal.visible = true
	$AnimationPlayer.play("menu_show")

func hide_menu_awal():
	$AnimationPlayer.play("menu_hide")
	await $AnimationPlayer.animation_finished
	$CanvasLayer/Menu_Awal.hide()
	$CanvasLayer/SaveMenu.modulate = Color(1, 1, 1, 0)
	$CanvasLayer/SaveMenu.show()
	$AnimationPlayer.play("save_show")

func _refresh_slots(animated_slot: int = -1) -> void:
	for child in slot_container.get_children():
		if child == add_button:
			continue

		slot_container.remove_child(child)
		child.queue_free()

	for slot_num in SaveManager.get_all_used_slots():
		_create_slot_ui(slot_num, slot_num == animated_slot)

	# Pindahkan tombol Add ke posisi paling bawah.
	slot_container.move_child(
		add_button,
		slot_container.get_child_count() - 1
	)

func _create_slot_ui(slot_num: int, animate: bool = false):
	var slot_ui = SAVE_SLOT_SCENE.instantiate()
	slot_container.add_child(slot_ui)
	slot_ui.set_slot_number(slot_num)  # cuma buat nampilin "Slot 1" dsb
	slot_ui.load_requested.connect(_on_slot_load.bind(slot_num))
	slot_ui.delete_requested.connect(_on_slot_delete.bind(slot_num, slot_ui))
	
	if animate:
		slot_ui.modulate = Color(1, 1, 1, 0)
		slot_ui.scale = Vector2(0.3, 0.3)
		slot_ui.pivot_offset = slot_ui.custom_minimum_size / 2.0
		var tween = create_tween().set_parallel(true)
		tween.tween_property(slot_ui, "modulate", Color(1, 1, 1, 1), 0.35)
		tween.tween_property(slot_ui, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_add_button_pressed():
	add_button.pivot_offset = add_button.size / 2.0
	var btn_tween = create_tween()
	btn_tween.tween_property(add_button, "scale", Vector2(0.9, 0.9), 0.08)
	btn_tween.tween_property(add_button, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	var new_slot := SaveManager.get_next_available_slot()
	SaveManager.create_new_slot(new_slot)
	_refresh_slots(new_slot)

func _on_slot_load(slot_num: int):
	SaveManager.set_slot(slot_num)
	SaveManager.load_game()
	get_tree().change_scene_to_file("res://Scene/main.tscn")  

func _on_slot_delete(slot_num: int, slot_ui: Control):
	for btn in slot_ui.find_children("", "Button", true, false):
		btn.disabled = true
		
	await get_tree().create_timer(0.1).timeout
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
	$AnimationPlayer.play("save_hide")
	await $AnimationPlayer.animation_finished
	$CanvasLayer/SaveMenu.hide()
	show_menu_awal()
