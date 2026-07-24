@tool
extends Control

@onready var templete_button=preload("res://Logic/object_For_skrip/tempelete_button.tscn")
@export var  skill_database:skill_obj

var buttons_by_id: Dictionary = {}
var opened_skill_ids: Array = []
var line_progress_by_id: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_skill_buttons()
	await get_tree().process_frame
	queue_redraw()
	
func _input(event: InputEvent) -> void:
	if Debug.is_active():
		if event.is_action_pressed("add_coin"):
			Point.add_point(100)
	
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
		#print("berhasil")
		add_child(new_btn)
		buttons_by_id[data.id] = new_btn
		new_btn.global_position = data.tree_position

		if data.required_skill_ids.is_empty():
			new_btn.visible = true
			line_progress_by_id[data.id] = 1.0

			if not opened_skill_ids.has(data.id):
				opened_skill_ids.append(data.id)
		else:
			new_btn.visible = false
			line_progress_by_id[data.id] = 0.0

		new_btn.get_node("Button").pressed.connect(_on_skill_button_pressedd.bind(data.id))
		urutan += 1
		
func _draw() -> void	:
	if skill_database == null:
		return

	for data in skill_database.skills:
		if data == null:
			continue

		var end_button = buttons_by_id.get(data.id) as Control

		if end_button == null:
			continue

		if end_button.visible == false:
			continue

		var imageend: Control = end_button.get_node("Image")
		var end_position = imageend.get_global_rect().get_center() - global_position

		for related_id in data.required_skill_ids:
			var start_button = buttons_by_id.get(related_id) as Control

			if start_button == null:
				print("Related ID tidak ditemukan: ", related_id)
				continue

			if start_button.visible == false:
				continue
			
			var image: Control = start_button.get_node("Image")
			var start_position = image.get_global_rect().get_center() - global_position

			var progress: float = float(
				line_progress_by_id.get(data.id, 1.0)
			)

			var animated_end: Vector2 = start_position.lerp(
				end_position,
				progress
			)

			draw_line(
				start_position,
				animated_end,
				Color.BROWN,
				3.0,
				true
			)

func _on_skill_button_pressedd(skil_id):
	#Point.remove_point(2)
	var targetSkill:skill=skill_database.get_skill_by_id(skil_id)
	#print(skil_id)
	if targetSkill.cost[targetSkill.level]<=Point.point:
		Point.remove_point(targetSkill.cost[targetSkill.level])
		print(targetSkill.level)
		targetSkill.level+=1
		for data in skill_database.skills:
			if data == null:
				continue
			if data.required_skill_ids.has(skil_id):
				var new_btn = buttons_by_id.get(data.id) as Control
		
				if new_btn == null:
					continue

				new_btn.visible = true
				if opened_skill_ids.has(data.id):
					continue

				opened_skill_ids.append(data.id)
				unlock_skill_animated(data.id, new_btn)
		queue_redraw()
	else:
		print("uang kurang")
		print(Point.point)
		print("kamu perlu ",targetSkill.cost[targetSkill.level])
		


func _set_line_progress(
	value: float,
	skill_id: String
) -> void:
	line_progress_by_id[skill_id] = value
	queue_redraw()


func unlock_skill_animated(
	skill_id: String,
	button: Control
) -> void:
	line_progress_by_id[skill_id] = 0.0

	button.visible = true
	button.pivot_offset = button.size * 0.5
	button.scale = Vector2(0.35, 0.35)
	button.modulate.a = 0.0

	# Animasi garis
	var line_tween := create_tween()

	line_tween.tween_method(
		_set_line_progress.bind(skill_id),
		0.0,
		1.0,
		0.45
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Animasi tombol muncul
	var button_tween := create_tween().set_parallel(true)

	button_tween.tween_property(
		button,
		"scale",
		Vector2.ONE,
		0.35
	).set_delay(0.20).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)

	button_tween.tween_property(
		button,
		"modulate:a",
		1.0,
		0.25
	).set_delay(0.20)
