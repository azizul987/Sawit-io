extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label
var misi_database=preload("res://Logic/Data Templete/Data/ress/Mission_Database.tres")
@export var mision:MissionDatabase

func  _ready() -> void:
	Point.point_change.connect(update_ui)
func update_ui(current_money: int):
	print(misi_database.get_mision(Point.idx_mision_now).target_value)
	print(Point.idx_mision_now)
	Point.idx_mision_now+=1
	SaveManager.save_game()
	progress_bar.value=Point.total_point_earned
	
