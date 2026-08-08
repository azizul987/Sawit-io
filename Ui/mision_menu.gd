extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

@export var mision:MissionDatabase

func  _ready() -> void:
	Point.point_change.connect(update_ui)

func update_ui(current_money: int):
	progress_bar.value=Point.total_point_earned
