@tool
extends Control

@onready var templete_button=preload("res://Logic/object_For_skrip/tempelete_button.tscn")
@export var  skill_database:skill_obj

var buttons_by_id: Dictionary = {}
var opened_skill_ids: Array = []
var line_progress_by_id: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveManager.load_skill_level(skill_database)
	generate_skill_buttons()
	await get_tree().process_frame
	queue_redraw()

func _process(delta: float) -> void:
	if buttons_by_id.is_empty():
		return

	queue_redraw()
	

func generate_skill_buttons():
	buttons_by_id.clear()
	opened_skill_ids.clear()
	line_progress_by_id.clear()

	if skill_database == null:
		print("databasenya lupa wak")
		return

	for data in skill_database.skills:
		if data == null:
			continue

		var new_btn = templete_button.instantiate()
		add_child(new_btn)

		buttons_by_id[data.id] = new_btn
		new_btn.global_position = data.tree_position

		var image_btn: TextureButton = new_btn.get_node("Image")
		image_btn.texture_normal = data.Icon
		
		var buy_btn: Button = new_btn.get_node("Buy")
		if data.level >= data.cost.size():
			buy_btn.text = "MAX"
		else:
			buy_btn.text = str(data.cost[data.level])
		_start_idle_skill_motion(new_btn, buttons_by_id.size())

		if data.required_skill_ids.is_empty():
			data.is_open = true

		new_btn.visible = data.is_open

		if data.is_open:
			line_progress_by_id[data.id] = 1.0

			if not opened_skill_ids.has(data.id):
				opened_skill_ids.append(data.id)
		else:
			line_progress_by_id[data.id] = 0.0

		new_btn.get_node("Buy").pressed.connect(_on_skill_button_pressedd.bind(data.id))
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
			
			var image: TextureButton = start_button.get_node("Image")
			var start_position = image.get_global_rect().get_center() - global_position

			var progress: float = float(
				line_progress_by_id.get(data.id, 1.0)
			)

			var animated_end: Vector2 = start_position.lerp(
				end_position,
				progress
			)
#
			#draw_line(
				#start_position,
				#animated_end,
				#Color.BLACK,
				#2.5,
				#true
			#)
			_draw_skill_line(start_position, animated_end)
func _on_skill_button_pressedd(skil_id):
	var select_btn=buttons_by_id.get(skil_id) as Control
	var targetSkill:skill=skill_database.get_skill_by_id(skil_id)
	#print("skill level is ",targetSkill.level)
	if targetSkill.level>=targetSkill.cost.size():
		return
	#print(skil_id)
	if targetSkill.cost[targetSkill.level]<=Point.point:
		Point.remove_point(targetSkill.cost[targetSkill.level])
		print(targetSkill.level)
	if targetSkill.level < targetSkill.cost.size():
		targetSkill.level += 1
		if targetSkill.level >= targetSkill.cost.size():
			select_btn.get_node("Buy").text = "MAX"
		else:
			select_btn.get_node("Buy").text = str(targetSkill.cost[targetSkill.level])
		SaveManager.save_skill_level(skill_database)
		for data in skill_database.skills:
			if data == null:
				continue
			if data.required_skill_ids.has(skil_id):
				var new_btn = buttons_by_id.get(data.id) as Control
		
				if new_btn == null:
					continue
				
				new_btn.visible = true
				data.is_open=true
				if opened_skill_ids.has(data.id):
					continue
				opened_skill_ids.append(data.id)
				unlock_skill_animated(data.id, new_btn)
		queue_redraw()
		SaveManager.save_skill_level(skill_database)
	else:
		#print("uang kurang")
		#print(Point.point)
		#print("kamu perlu ",targetSkill.cost[targetSkill.level])
		pass
		


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


func _start_idle_skill_motion(target: Control, delay_index: int) -> void:
	if Engine.is_editor_hint():
		return

	await get_tree().process_frame

	var base_pos := target.position

	var arah := 1.0
	if delay_index % 2 == 0:
		arah = -1.0

	var gerak := Vector2(4.0 * arah, -3.0)

	var tween := create_tween()
	tween.set_loops()

	tween.tween_interval(float(delay_index % 5) * 0.08)

	tween.tween_property(
		target,
		"position",
		base_pos + gerak,
		0.7
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		target,
		"position",
		base_pos,
		0.7
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	

func _draw_skill_line(start_pos: Vector2, end_pos: Vector2) -> void:
	var points := PackedVector2Array()

	var mid := (start_pos + end_pos) * 0.5
	var control := mid + Vector2(0, -35)

	for i in range(16):
		var t := float(i) / 15.0

		var a := start_pos.lerp(control, t)
		var b := control.lerp(end_pos, t)
		var p := a.lerp(b, t)

		points.append(p)

	draw_polyline(points, Color(0.0, 0.234, 0.097, 0.55), 7.0, true)
	draw_polyline(points, Color(0.242, 0.394, 0.139, 0.95), 3.0, true)
