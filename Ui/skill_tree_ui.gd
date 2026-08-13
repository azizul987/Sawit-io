extends Control

@onready var rebirth_point_label: Label = $CanvasLayer/MarginContainer/RebirthPointLabel
@onready var deskripsi_skill_perlevel: Label = $CanvasLayer/Deskripsi_Skill_Perlevel

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
	var canvas = $"SubViewportContainer/SubViewport/Skill Tree/Canvas/SkiilCanvas"
	canvas.skill_hovered.connect(func(teks: String):
		deskripsi_skill_perlevel.text = teks
	)
	canvas.skill_unhovered.connect(func():
		deskripsi_skill_perlevel.text = ""
	)

func eksekusi_rebirth() -> void:
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

func _process(delta: float) -> void:
	rebirth_point_label.text=str(Point.rebirth_point)

func _on_exit_pressed() -> void:
	$".".hide()
	var ui_main = $"../../CanvasLayer/UiMain"
	ui_main.skillshow.show()
	ui_main.get_node("UpdateMenu").show()
