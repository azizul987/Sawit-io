@tool
extends CollisionPolygon2D

func _ready() -> void:
	# Beri sedikit jeda agar semua node dalam parent selesai dimuat
	call_deferred("samakan_bentuk_polygon")

func samakan_bentuk_polygon() -> void:
	var parent = get_parent()
	
	# Cari semua "saudara" (child dari parent yang sama)
	for child in parent.get_children():
		# Jika menemukan node Polygon2D
		if child is Polygon2D:
			# 1. Copy susunan titiknya (bentuk)
			self.polygon = child.polygon
			
			# 2. Copy posisi tepatnya di layar
			self.position = child.position
			
			# 3. Copy rotasi dan skala (biar 100% sama persis ukurannya)
			self.rotation = child.rotation
			self.scale = child.scale
			
			# Hentikan pencarian setelah ketemu satu
			break
