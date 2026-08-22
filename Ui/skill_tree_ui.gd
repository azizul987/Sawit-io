extends Control

@onready var rebirth_point_label: Label = $CanvasLayer/MarginContainer/RebirthPointLabel
@onready var deskripsi_skill_perlevel: Label = $CanvasLayer/Deskripsi_Skill_Perlevel
@onready var rebirth_btn: Button = $CanvasLayer/Rebirth

var _skill_canvas: Control
@onready var _konfirmasi_panel: PanelContainer = $CanvasLayer/KonfirmasiPanel

func _ready() -> void:
	visibility_changed.connect(func():
		Point.is_skill_tree_open = visible
		if has_node("CanvasLayer"):
			$CanvasLayer.visible = visible
	)
	Point.is_skill_tree_open = visible
	if has_node("CanvasLayer"):
		$CanvasLayer.visible = visible

	# Sambungkan signal hover dari SkiilCanvas ke label deskripsi
	_skill_canvas = $"SubViewportContainer/SubViewport/Skill Tree/Canvas/SkiilCanvas"
	_skill_canvas.skill_hovered.connect(func(teks: String):
		deskripsi_skill_perlevel.text = teks
	)
	_skill_canvas.skill_unhovered.connect(func():
		deskripsi_skill_perlevel.text = ""
	)

func eksekusi_rebirth() -> void:
	# Kunci semua level skill yang sudah dialokasikan jadi permanen
	if _skill_canvas and _skill_canvas.skill_database:
		for sk in _skill_canvas.skill_database.skills:
			if sk != null:
				sk.locked_level = sk.level
		SaveManager.save_skill_level(_skill_canvas.skill_database)

	Point.point = 1.0
	Point.total_point_earned = 1.0
	Point.tipe_wilayah_terbuka = 2
	Point.TipeWilayahArray = Vector3i(0, 0, 1)
	Point.main_tree_camera = Vector3(7347.983, 8094.0, 1)
	Point.skill_tree_camera = Vector3(0, 0, 1.4)
	
	var save_data = SaveManager.read_save_data()
	if save_data.has("wilayah"):
		save_data.erase("wilayah")
	if save_data.has("upgrades"):
		save_data.erase("upgrades")
	
	SaveManager.write_save_data(save_data)
	SaveManager.save_game()
	
	var up_db = load("res://Logic/Data Templete/Data/ress/updatedatabase.tres")
	if up_db:
		for up in up_db.upgrades:
			if up != null:
				up.current_level = 0
	
	get_tree().reload_current_scene()

func _ada_skill_teralokasi() -> bool:
	if _skill_canvas == null or _skill_canvas.skill_database == null:
		return false
	for sk in _skill_canvas.skill_database.skills:
		if sk != null and sk.level > sk.locked_level:
			return true
	return false

func _on_rebirth_btn_pressed() -> void:
	_konfirmasi_panel.visible = true

func _on_konfirmasi_batal() -> void:
	_konfirmasi_panel.visible = false

func _on_konfirmasi_ya() -> void:
	_konfirmasi_panel.visible = false

	var transisi = get_tree().get_nodes_in_group("transi")

	for tra in transisi:
		await tra.fade_in()

	eksekusi_rebirth()

func _process(delta: float) -> void:
	rebirth_point_label.text = str(Point.rebirth_point)
	var bisa_rebirth := _ada_skill_teralokasi()
	if bisa_rebirth and rebirth_btn.disabled:
		HintManager.show_hint("rebirth_ready", "Rebirth tersedia!\nProgress reset, skill tetap tersimpan.")
	rebirth_btn.disabled = not bisa_rebirth

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Kalau panel konfirmasi lagi terbuka, klik di luar panel → tutup konfirmasi
		if _konfirmasi_panel.visible:
			var konfirmasi_rect = _konfirmasi_panel.get_global_rect()
			if not konfirmasi_rect.has_point(event.global_position):
				_on_konfirmasi_batal()
				get_viewport().set_input_as_handled()
			return
		# Kalau panel konfirmasi tutup, klik di luar skill tree → tutup skill tree
		var panel_rect = $NinePatchRect.get_global_rect()
		if not panel_rect.has_point(event.global_position):
			_on_exit_pressed()
			get_viewport().set_input_as_handled()

func _on_exit_pressed() -> void:
	$".".hide()
	var ui_main = $"../../CanvasLayer/UiMain"
	ui_main.skillshow.show()
	ui_main.get_node("UpdateMenu").show()
