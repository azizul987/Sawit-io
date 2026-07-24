extends Polygon2D
#func _ready() -> void:
	## 1. Mendapatkan semua titik koordinat dari poligon
	#var titik_titik = polygon
	#
	## Mencetak koordinat tiap titik satu per satu ke tab Output
	#for i in range(titik_titik.size()):
		#print("Titik ke-", i, " posisinya di: ", titik_titik[i])
		#
	## 2. Menghitung dan menampilkan luas poligon
	#var luas = hitung_luas(titik_titik)
	#print("Luas poligon ini adalah: ", luas, " pixel persegi")
#
#
## Fungsi khusus untuk menghitung luas dengan Rumus Shoelace
#func hitung_luas(points: PackedVector2Array) -> float:
	#var jumlah_titik = points.size()
	#
	## Poligon minimal harus punya 3 titik (segitiga). Kalau kurang, luasnya 0.
	#if jumlah_titik < 3:
		#return 0.0
		#
	#var luas_sementara: float = 0.0
	#
	#for i in range(jumlah_titik):
		## Ambil titik saat ini
		#var titik_sekarang = points[i]
		#
		## Ambil titik berikutnya. 
		## Penggunaan modulo (%) berfungsi agar titik terakhir kembali menyambung ke titik pertama (index 0).
		#var titik_berikutnya = points[(i + 1) % jumlah_titik]
		#
		## Terapkan perkalian silang sesuai rumus
		#luas_sementara += (titik_sekarang.x * titik_berikutnya.y) - (titik_sekarang.y * titik_berikutnya.x)
		#
	## Hasil akhir adalah setengah dari nilai mutlak (absolut) perkalian silang tadi
	#return abs(luas_sementara) / 2.0
