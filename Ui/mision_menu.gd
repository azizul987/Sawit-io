extends Control

@onready var progress_bar: ProgressBar = $"."
@onready var label: Label = 	$"../Label"
var misi_database=preload("res://Logic/Data Templete/Data/ress/Mission_Database.tres")
var upgrade_database = preload("res://Logic/Data Templete/Data/ress/updatedatabase.tres")
var confetti_scene = preload("res://Ui/EffectConfetti.tscn")

@export var mision:MissionDatabase

func _ready() -> void:
	Point.point_change.connect(update_ui)
	progress_bar.max_value=mision.get_mision(Point.idx_mision_now).target_value
	progress_bar.value=get_current_progress(mision.get_mision(Point.idx_mision_now))
	update_label(mision.get_mision(Point.idx_mision_now))

func get_current_progress(misi: Mission) -> float:
	match misi.requirement_type:
		Mission.RequirementType.TOTAL_POINT_REACHED:
			return Point.total_point_earned
		Mission.RequirementType.UPGRADE_LEVEL_REACHED:
			for u in upgrade_database.upgrades:
				if u and u.upgrade_name == misi.target_upgrade_name:
					return float(u.current_level)
			return 0.0
		Mission.RequirementType.WILAYAH_TERBUKA:
			var count = 0
			for w in get_tree().get_nodes_in_group("wilayah"):
				if w.data and w.data.terbuka_default:
					count += 1
			return float(count)
	return 0.0

func update_ui(_add_poin: int):
	var Mision_Type = misi_database.get_mision(Point.idx_mision_now)
	if mision_comparator(Mision_Type) && !is_max():
		spawn_confetti()
		Point.idx_mision_now += 1
		Point.rebirth_point += Mision_Type.reward_rebirth_point
		progress_bar.max_value = mision.get_mision(Point.idx_mision_now).target_value
	
	progress_bar.value = get_current_progress(mision.get_mision(Point.idx_mision_now))
	update_label(mision.get_mision(Point.idx_mision_now))
	SaveManager.save_game()

func mision_comparator(misi: Mission):
	return get_current_progress(misi) >= misi.target_value

func update_label(misi: Mission):
	if not is_max():
		var prog = Point.format_num(get_current_progress(misi))
		var tgt = Point.format_num(misi.target_value)
		
		match misi.requirement_type:
			Mission.RequirementType.TOTAL_POINT_REACHED:
				label.text = "Kumpulkan uang:{0}/{1} ".format([prog, tgt])
			Mission.RequirementType.UPGRADE_LEVEL_REACHED:
				label.text = "{0}:{1}/{2} ".format([misi.target_upgrade_name, prog, tgt])
			Mission.RequirementType.WILAYAH_TERBUKA:
				label.text = "Buka Wilayah:{0}/{1} ".format([prog, tgt])
	else:
		label.text = "Semua Misi Selesai:MAX/MAX "

func is_max():
	return Point.idx_mision_now >= len(misi_database.missions)

func spawn_confetti():
	var particles = confetti_scene.instantiate()
	
	add_child(particles)
	# Set global_position sesudah add_child agar koordinatnya benar-benar di tengah layar
	particles.global_position = get_viewport_rect().size / 2
