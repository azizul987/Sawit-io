extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label
var misi_database=preload("res://Logic/Data Templete/Data/ress/Mission_Database.tres")
@export var mision:MissionDatabase

func  _ready() -> void:
	Point.point_change.connect(update_ui)
	progress_bar.max_value=mision.get_mision(Point.idx_mision_now).target_value
	update_label(mision.get_mision(Point.idx_mision_now))
func update_ui(add_poin: int):
	var Mision_Type = misi_database.get_mision(Point.idx_mision_now)
	if mision_comparator(Mision_Type):
		Point.idx_mision_now+=1
		progress_bar.max_value=mision.get_mision(Point.idx_mision_now).target_value
	progress_bar.value=Point.total_point_earned
	update_label(mision.get_mision(Point.idx_mision_now))
	SaveManager.save_game()
	

func mision_comparator(misi:Mission):
	return  Point.total_point_earned>=misi.target_value
func update_label(misi:Mission):
	label.text="Kumpulkan uang:{0}/{1} ".format([Point.format_num(Point.total_point_earned),Point.format_num(misi.target_value)])
