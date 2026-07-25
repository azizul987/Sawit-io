extends Node

var daftar_wilayah: Array = []


func _ready() -> void:
	ambil_semua_wilayah()


func ambil_semua_wilayah() -> void:
	daftar_wilayah = get_tree().get_nodes_in_group("wilayah")

	print("Jumlah wilayah: ", daftar_wilayah.size())
