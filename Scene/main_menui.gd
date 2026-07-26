extends Node2D

const SAVE_SLOT_SCENE = preload("res://Logic/object_For_skrip/SaveSlotItem.tscn")

@onready var slot_container = $CanvasLayer/SaveMenu/ScrollContainer/VBoxContainer
@onready var add_button =$CanvasLayer/SaveMenu/Add
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
	#visible = false-
	#await $AnimationPlayer.animation_finished
	$CanvasLayer/SaveMenu.show()

func _refresh_slots():
	for child in slot_container.get_children():
		child.queue_free()
	for slot_num in SaveManager.get_all_used_slots():
		_create_slot_ui(slot_num)

func _create_slot_ui(slot_num: int):
	var slot_ui = SAVE_SLOT_SCENE.instantiate()
	slot_container.add_child(slot_ui)
	slot_ui.set_slot_number(slot_num)  # cuma buat nampilin "Slot 1" dsb
	slot_ui.load_requested.connect(_on_slot_load.bind(slot_num))
	slot_ui.delete_requested.connect(_on_slot_delete.bind(slot_num))

func _on_add_button_pressed():
	var new_slot := SaveManager.get_next_available_slot()
	SaveManager.set_slot(new_slot)
	SaveManager.save_game()
	_refresh_slots()

func _on_slot_load(slot_num: int):
	SaveManager.set_slot(slot_num)
	get_tree().change_scene_to_file("res://Scene/main.tscn")  # scene tujuan yang udah punya logic load sendiri

func _on_slot_delete(slot_num: int):
	SaveManager.delete_slot(slot_num)
	_refresh_slots()
