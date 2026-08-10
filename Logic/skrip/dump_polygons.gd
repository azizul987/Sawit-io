extends SceneTree
func _init():
	var scene = load("res://Scene/main.tscn").instantiate()
	for child in scene.get_node("map").get_children():
		if child.is_in_group("wilayah"):
			var poly = child.get_node_or_null("Polygon2D")
			if poly:
				print("Group: wilayah, Node: " + child.name + ", points: " + str(poly.polygon.size()))
		for subchild in child.get_children():
			if subchild.is_in_group("wilayah"):
				var poly = subchild.get_node_or_null("Polygon2D")
				if poly:
					print("Group: wilayah, Node: " + subchild.name + ", points: " + str(poly.polygon.size()))
			for subsubchild in subchild.get_children():
				if subsubchild.is_in_group("wilayah"):
					var poly = subsubchild.get_node_or_null("Polygon2D")
					if poly:
						print("Group: wilayah, Node: " + subsubchild.name + ", points: " + str(poly.polygon.size()))
	quit()
