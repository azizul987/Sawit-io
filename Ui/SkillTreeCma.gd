extends Camera2D

@export var move_speed := 500.0
@export var zoom_speed := 0.1
@export var min_zoom := 0.5
@export var max_zoom := 2.5

var is_dragging := false

func _ready() -> void:
	position.x=Point.skill_tree_camera.x
	position.y=Point.skill_tree_camera.y
	zoom=Vector2(Point.skill_tree_camera.z,Point.skill_tree_camera.z)

func _process(delta: float) -> void:
	var direction := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1

	if Input.is_action_pressed("ui_left"):
		direction.x -= 1

	if Input.is_action_pressed("ui_down"):
		direction.y += 1

	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		position += direction.normalized() * move_speed * delta

	if Input.is_action_just_pressed("zoom_in"):
		zoom_camera(-zoom_speed)

	if Input.is_action_just_pressed("zoom_out"):
		zoom_camera(zoom_speed)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_dragging = event.pressed
			

	if event is InputEventMouseMotion and is_dragging:
		position -= event.relative / zoom.x
		Point.skill_tree_camera.x=position.x
		Point.skill_tree_camera.y=position.y
		SaveManager.save_game()

func zoom_camera(value):
	var new_zoom = zoom.x + value
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)
	Point.skill_tree_camera.z=zoom.x 
	SaveManager.save_game()
