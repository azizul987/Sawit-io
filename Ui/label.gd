extends Control

@onready var  skor=$CanvasLayer/Point
@onready var skillshow=$"CanvasLayer/SkillTree/Change _Mode"
# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	$"../../CanvasLayer2/SkillTreeUi".show()
	SaveManager.save_game()
	skillshow.hide()

	
	

func _on_exit_pressed() -> void:
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://Scene/MainMenui.tscn")
