extends Node


var point =10011
var cd=1
var skill_tree_camera:Vector3
var main_tree_camera:Vector2
func add_point(value):
	point += value 
	#print("Point sekarang: ", point)
	SaveManager.save_game()

func remove_point(value): 
	point -= value
	if point < 0:
		point = 0
	#print("Point sekarang: ", point)
