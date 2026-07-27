extends Control

@onready var  skor=$CanvasLayer/Point
# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	SaveManager.load_game()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	skor.text=str(Point.point)
	

func print_scene_name() -> void:
	if not is_inside_tree():
		print("Node belum masuk tree")
		return

	var tree := get_tree()

	if tree == null:
		print("SceneTree masih null")
		return

	var current := tree.current_scene

	if current == null:
		print("current_scene masih null")
		return

	print("Nama scene:", current.name)
	print("Path scene:", current.scene_file_path)


func _on_texture_button_pressed() -> void:
	var current_scene := get_tree().current_scene

	if current_scene == null:
		return

	var current_path := current_scene.scene_file_path
	var target_path: String

	if current_path == "res://Scene/main.tscn":
		target_path = "res://Ui/skill_tree.tscn"
	elif current_path == "res://Ui/skill_tree.tscn":
		target_path = "res://Scene/main.tscn"
	else:
		push_error("Scene tidak dikenali: " + current_path)
		return

	SaveManager.save_game()

	var error := get_tree().change_scene_to_file(target_path)

	if error != OK:
		push_error("Gagal membuka scene: " + target_path)
	
	
func _input(event: InputEvent) -> void:
	if Debug.is_active():
		if event.is_action_pressed("add_coin"):
			Point.add_point(100)
		if event.is_action("delete_save"):
			SaveManager.delete_current_save()


func _on_exit_pressed() -> void:
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://Scene/MainMenui.tscn")
