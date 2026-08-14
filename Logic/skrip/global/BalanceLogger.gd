extends Node
const LOG_PATH := "user://balance_log.csv"

var _file: FileAccess
var _game_time: float = 0.0


func _ready() -> void:
	_open_log_file()
	if Point.has_signal("pps_updated"):
		Point.pps_updated.connect(_on_pps_updated)


func _process(delta: float) -> void:
	_game_time += delta


func _open_log_file() -> void:
	var file_exists := FileAccess.file_exists(LOG_PATH)
	_file = FileAccess.open(LOG_PATH, FileAccess.READ_WRITE if file_exists else FileAccess.WRITE)
	if _file == null:
		push_error("BalanceLogger: gagal buka file log di " + LOG_PATH)
		return
	if not file_exists:
		_write_header()
	else:
		_file.seek_end()


func _write_header() -> void:
	_file.store_line(
		"timestamp_unix,game_time_sec,event_type,item_name,level_baru," +
		"harga_dibayar,mata_uang,effect_type,effect_value_baru," +
		"stat_sebelum,stat_sesudah,persen_kenaikan,point_balance,pps_saat_itu," +
		"jumlah_wilayah_terbuka,nama_wilayah_terbuka,jumlah_pohon,jumlah_buruh"
	)


func _write_row(values: Array) -> void:
	if _file == null:
		return
	var escaped := []
	for v in values:
		var s := str(v)
		if "," in s or "\"" in s:
			s = "\"" + s.replace("\"", "\"\"") + "\""
		escaped.append(s)
	_file.store_line(",".join(escaped))
	_file.flush()


func _percent_naik(sebelum: float, sesudah: float) -> float:
	if sebelum == 0.0:
		return 0.0
	return ((sesudah - sebelum) / sebelum) * 100.0


func _get_jumlah_pohon() -> int:
	return get_tree().get_nodes_in_group("sawit_visual").size()


func _get_jumlah_buruh() -> int:
	return get_tree().get_nodes_in_group("buruh_visual").size()


func _get_wilayah_terbuka() -> Array:
	var hasil: Array = []
	for w in get_tree().get_nodes_in_group("wilayah"):
		if w.data and w.data.terbuka_default:
			hasil.append(w.data.nama_wilayah)
	return hasil


func _get_snapshot_dunia() -> Array:
	var wil_terbuka := _get_wilayah_terbuka()
	return [
		wil_terbuka.size(),
		"; ".join(wil_terbuka),
		_get_jumlah_pohon(),
		_get_jumlah_buruh()
	]


func log_upgrade_purchase(
	upgrade_data: UpgradeData,
	harga_dibayar: float,
	point_per_click_sebelum: float,
	point_per_click_sesudah: float
) -> void:
	var dunia := _get_snapshot_dunia()
	_write_row([
		Time.get_unix_time_from_system(),
		"%.1f" % _game_time,
		"UPGRADE",
		upgrade_data.upgrade_name,
		upgrade_data.current_level,
		harga_dibayar,
		"point",
		upgrade_data.effect_type,
		upgrade_data.effect_value,
		point_per_click_sebelum,
		point_per_click_sesudah,
		"%.2f" % _percent_naik(point_per_click_sebelum, point_per_click_sesudah),
		Point.point,
		Point.points_per_second,
		dunia[0], dunia[1], dunia[2], dunia[3]
	])


func log_skill_purchase(
	skill_data: skill,
	rebirth_point_dibayar: int,
	stat_sebelum: float,
	stat_sesudah: float
) -> void:
	var dunia := _get_snapshot_dunia()
	_write_row([
		Time.get_unix_time_from_system(),
		"%.1f" % _game_time,
		"SKILL",
		skill_data.skill_name,
		skill_data.level,
		rebirth_point_dibayar,
		"rebirth_point",
		skill_data.effect_type,
		skill_data.effect_value,
		stat_sebelum,
		stat_sesudah,
		"%.2f" % _percent_naik(stat_sebelum, stat_sesudah),
		Point.point,
		Point.points_per_second,
		dunia[0], dunia[1], dunia[2], dunia[3]
	])



func log_wilayah_purchase(
	wilayah_data: Wilayah,
	harga_dibayar: float
) -> void:
	var dunia := _get_snapshot_dunia()
	_write_row([
		Time.get_unix_time_from_system(),
		"%.1f" % _game_time,
		"WILAYAH",
		wilayah_data.nama_wilayah,
		"-",
		harga_dibayar,
		"point",
		"-", "-", "-", "-", "-",
		Point.point,
		Point.points_per_second,
		dunia[0], dunia[1], dunia[2], dunia[3]
	])


func _on_pps_updated(new_pps: float) -> void:
	var dunia := _get_snapshot_dunia()
	_write_row([
		Time.get_unix_time_from_system(),
		"%.1f" % _game_time,
		"PPS_SNAPSHOT",
		"-", "-", "-", "-", "-", "-", "-", "-", "-",
		Point.point,
		new_pps,
		dunia[0], dunia[1], dunia[2], dunia[3]
	])
