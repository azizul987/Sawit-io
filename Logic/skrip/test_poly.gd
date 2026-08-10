extends SceneTree

func _init():
    var scene = load("res://Scene/main.tscn").instantiate()
    for w in scene.get_node("map").get_children():
        if w.has_node("Polygon2D"):
            var p = w.get_node("Polygon2D")
            print(w.name, " points size: ", p.polygon.size())
    quit()
