extends SceneTree
func _init():
    var main = load("res://Scene/main.tscn").instantiate()
    var map = main.get_node("map")
    map.ambil_semua_wilayah()
    var total_luas = 0.0
    for w in map.daftar_wilayah:
        if w.data and w.data.terbuka_default:
            var poly = w.get_node_or_null("Polygon2D")
            if poly:
                var titik = poly.polygon
                var luas = 0.0
                for i in range(titik.size()):
                    var p0 = titik[i]
                    var p1 = titik[(i + 1) % titik.size()]
                    luas += p0.cross(p1)
                luas = absf(luas * 0.5)
                var global_scale = poly.global_scale
                print("Wilayah: ", w.name, " luas lokal: ", luas, " scale: ", global_scale, " global luas: ", luas * global_scale.x * global_scale.y)
                total_luas += luas * global_scale.x * global_scale.y
    print("Total Luas: ", total_luas)
    var max_cap = max(10, int(total_luas / 1500.0))
    print("Max Cap: ", max_cap)
    quit()
