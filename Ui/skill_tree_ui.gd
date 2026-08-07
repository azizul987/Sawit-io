extends Control


func _ready() -> void:
	visibility_changed.connect(func(): Point.is_skill_tree_open = visible)
	Point.is_skill_tree_open = visible


func _on_exit_pressed() -> void:
	$".".hide()
	var ui_main = $"../../CanvasLayer/UiMain"
	ui_main.skillshow.show()
	ui_main.get_node("UpdateMenu").show()
