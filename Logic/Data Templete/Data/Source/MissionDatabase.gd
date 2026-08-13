class_name MissionDatabase
extends Resource

@export var missions: Array[Mission] = []

func  get_mision(idx:int):
	if idx<len(missions): return missions[idx]
	return missions[0]
