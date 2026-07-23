extends Control

@onready var templete_button=preload("res://Logic/object_For_skrip/tempelete_button.tscn")
@export var  skill_database:skill_obj

var buttons_by_id: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_skill_buttons()
	await get_tree().process_frame
	queue_redraw()
	
func  generate_skill_buttons():
	buttons_by_id.clear()
	if skill_database==null:
		print("databasenya lupa wak")
		return
	var urutan = 0
	for data  in skill_database.skills:
		if data==null:
			continue
		var new_btn=templete_button.instantiate()
		print("berhasil")
		add_child(new_btn)
		buttons_by_id[data.id] = new_btn
		new_btn.global_position = data.tree_position
		urutan += 1
		
func _draw() -> void	:
	if skill_database == null:
		return
	for data in skill_database.skills:
		if data == null:
			continue

		var start_button = buttons_by_id.get(data.id) as Control

		if start_button == null:
			continue
		
		var image: Control = start_button.get_node("Image")
		var start_position = image.get_global_rect().get_center() - global_position

		for related_id in data.required_skill_ids:
			var end_button = buttons_by_id.get(related_id) as Control

			if end_button == null:
				print("Related ID tidak ditemukan: ", related_id)
				continue
			
			var imageend: Control = end_button.get_node("Image")
			var end_position = imageend.get_global_rect().get_center() - global_position

			draw_line(
				start_position,
				end_position,
				Color.BROWN,
				3.0,
				true
			)
