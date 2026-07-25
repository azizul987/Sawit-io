extends Camera2D

@export var move_speed := 500.0
<<<<<<< Updated upstream
@export var zoom_speed := 0.25
@export var min_zoom := 0.1
@export var max_zoom := 10

=======
@export var zoom_speed := 0.1
@export var min_zoom := 5.2
@export var max_zoom := 2
>>>>>>> Stashed changes
var is_dragging := false


func _ready() -> void:
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


func zoom_camera(value: float) -> void:
	var new_zoom := zoom.x + value
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)

	zoom = Vector2(new_zoom, new_zoom)
