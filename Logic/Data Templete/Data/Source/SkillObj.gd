class_name skill_obj

extends  Resource

@export var skills:Array[skill]=[]
func get_skill_by_id(target_id: String) -> skill:
	var index := skills.find_custom(
		func(data: skill) -> bool:
			return data != null and data.id == target_id
	)

	if index == -1:
		return null

	return skills[index]
