extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label
var misi_database=preload("res://Logic/Data Templete/Data/ress/Mission_Database.tres")
@export var mision:MissionDatabase

func  _ready() -> void:
	Point.point_change.connect(update_ui)
func update_ui(add_poin: int):
	var Mision_Type = misi_database.get_mision(Point.idx_mision_now)
	if mision_comparator(Mision_Type):
		pass
	Point.idx_mision_now+=1
	progress_bar.value+=add_poin
	SaveManager.save_game()
	

func mision_comparator(misi:Mission):
	return  Point.total_point_earned>misi.target_value
