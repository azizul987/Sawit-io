extends Control


func _ready() -> void:
	visibility_changed.connect(func(): Point.is_skill_tree_open = visible)
	Point.is_skill_tree_open = visible


func _on_exit_pressed() -> void:
	$".".hide()
	$"../../CanvasLayer/UiMain".skillshow.show()
