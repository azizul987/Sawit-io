class_name Area
extends Resource
enum TipeWilayah {
	PROVINSI,
	KABUPATEN,
	KECAMATAN
}

@export_group("Informasi Wilayah")
@export var id_wilayah: StringName
@export var nama_wilayah: String
@export var tipe_wilayah: TipeWilayah = TipeWilayah.PROVINSI

@export_group("Pembelian")
@export var harga: int = 1000
@export var terbuka_default: bool = false

@export_group("Tampilan")
@export var warna_terbuka: Color = Color("#7a4408")
@export var warna_terkunci: Color = Color.GRAY
