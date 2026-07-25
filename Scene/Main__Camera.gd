extends Camera2D

@export var move_speed := 500.0
@export var zoom_speed := 0.25
@export var min_zoom := 0.1
@export var max_zoom := 10.0

var is_dragging := false


func _ready() -> void:
	SaveManager.load_game()
	position = Vector2(
		Point.main_tree_camera.x,
		Point.main_tree_camera.y
	)

	zoom = Vector2(
		Point.main_tree_camera.z,
		Point.main_tree_camera.z
	)

	make_current()


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
		simpan_posisi_camera()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_dragging = event.pressed

		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_camera(zoom_speed)

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_camera(-zoom_speed)

	if event is InputEventKey and event.pressed and not event.echo:
		if event.is_action_pressed("zoom_in"):
			zoom_camera(zoom_speed)

		if event.is_action_pressed("zoom_out"):
			zoom_camera(-zoom_speed)

	if event is InputEventMouseMotion and is_dragging:
		position -= event.relative / zoom.x
		simpan_posisi_camera()


func zoom_camera(value: float) -> void:
	var new_zoom := zoom.x + value
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)

	zoom = Vector2(new_zoom, new_zoom)
	simpan_posisi_camera()


func simpan_posisi_camera() -> void:
	Point.main_tree_camera.x = position.x
	Point.main_tree_camera.y = position.y
	Point.main_tree_camera.z = zoom.x

	SaveManager.save_game()
