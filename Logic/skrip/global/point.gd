extends Node


var point =10011
var cd=1
func add_point(value):
	point += value 
	print("Point sekarang: ", point)

func remove_point(value): 
	point -= value
	if point < 0:
		point = 0
	print("Point sekarang: ", point)
