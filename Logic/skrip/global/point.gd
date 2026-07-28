extends Node


var point =0
var point_per_click:float=2.5
var cd=1
var skill_tree_camera:Vector3
var main_tree_camera:Vector3
var is_skill_tree_open: bool = false
func add_point(value):
	point += value 
	#print("Point sekarang: ", point)
	SaveManager.save_game()

func remove_point(value): 
	point -= value
	if point < 0:
		point = 0
	#print("Point sekarang: ", point)

func _input(event: InputEvent) -> void:
	if Debug.is_active():
		if event.is_action_pressed("add_coin"):
			Point.add_point(100)
		if event.is_action("delete_save"):
			SaveManager.delete_current_save()
