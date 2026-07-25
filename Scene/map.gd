@tool
extends Node

@export var warna_border: Color = Color.WHITE
@export var tebal_border: float = 1

var daftar_wilayah: Array = []


func _ready() -> void:
	await get_tree().process_frame

	ambil_semua_wilayah()
	perbarui_semua_border()


func ambil_semua_wilayah() -> void:
	daftar_wilayah = get_tree().get_nodes_in_group("wilayah")

	print("Jumlah wilayah: ", daftar_wilayah.size())


func perbarui_semua_border() -> void:
	for wilayah in daftar_wilayah:
		perbarui_border_wilayah(wilayah)

func perbarui_border_wilayah(wilayah: Node) -> void:
	var polygon := wilayah.get_node_or_null("Polygon2D") as Polygon2D
	var border := wilayah.get_node_or_null("Line2D") as Line2D
	if polygon == null or border == null:
		return
	var titik := polygon.polygon
	if titik.size() < 2:
		return

	border.top_level = true
	border.clear_points()
	border.position = Vector2.ZERO
	border.rotation = 0.0
	border.scale = Vector2.ONE

	for p in titik:
		border.add_point(polygon.global_transform * (p + polygon.offset))
	border.add_point(polygon.global_transform * (titik[0] + polygon.offset))

	border.default_color = warna_border
	border.width = tebal_border
	border.joint_mode = Line2D.LINE_JOINT_ROUND
	border.begin_cap_mode = Line2D.LINE_CAP_ROUND
	border.end_cap_mode = Line2D.LINE_CAP_ROUND
	border.antialiased = true
	border.z_index = polygon.z_index + 1
