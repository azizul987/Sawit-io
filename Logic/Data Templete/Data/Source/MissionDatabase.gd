class_name MissionDatabase
extends Resource

@export var missions: Array[Mission] = []

func get_mision(idx: int) -> Mission:
	if idx >= 0 and idx < missions.size():
		return missions[idx]
	return null
func get_mision_type(idx:int):
	if idx<len(missions): return missions[idx].requirement_type
	return 0
