extends SceneTree
func _init():
	var arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
	var counts = {}
	for i in 55:
		var val = arr.pick_random()
		counts[val] = counts.get(val, 0) + 1
	print(counts)
	quit()
