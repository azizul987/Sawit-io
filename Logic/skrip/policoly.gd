#@tool
extends CollisionPolygon2D

func _ready() -> void:
	# Beri sedikit jeda agar semua node dalam parent selesai dimuat
	call_deferred("samakan_bentuk_polygon")

func samakan_bentuk_polygon() -> void:
	var parent = get_parent()
	var polygons: Array[Polygon2D] = []
	var collisions: Array[CollisionPolygon2D] = []
	
	# Kumpulkan semua Polygon2D dan CollisionPolygon2D
	for child in parent.get_children():
		if child is Polygon2D:
			polygons.append(child)
		elif child is CollisionPolygon2D:
			collisions.append(child)
	
	# Pasangkan CollisionPolygon2D ke-N dengan Polygon2D ke-N
	var my_index = collisions.find(self)
	if my_index != -1 and my_index < polygons.size():
		var target = polygons[my_index]
		self.polygon = target.polygon
		self.position = target.position
		self.rotation = target.rotation
		self.scale = target.scale
