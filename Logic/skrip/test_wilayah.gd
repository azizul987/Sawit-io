extends SceneTree

func _init():
    var scene = load("res://Scene/main.tscn").instantiate()
    var wilayahs = scene.get_tree().get_nodes_in_group("wilayah")
    print("Found wilayah: ", wilayahs.size())
    for w in wilayahs:
        if w.has_node("Polygon2D"):
            var p = w.get_node("Polygon2D")
            print("  ", w.name, " points size: ", p.polygon.size())
    quit()
