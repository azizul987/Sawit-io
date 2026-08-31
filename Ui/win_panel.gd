extends CanvasLayer

@onready var panel: PanelContainer = $Overlay/CenterContainer/PanelContainer
@onready var continue_button: Button = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Continue
@onready var main_menu_button: Button = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MainMenu

var _win_shown: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("win_condition")
	hide()

	continue_button.pressed.connect(_on_continue_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	# Fallback untuk load save: tunggu Upgrade UI selesai menghitung kapasitas dinamis.
	await get_tree().create_timer(0.25).timeout
	check_win_condition()

func check_win_condition() -> void:
	if _win_shown:
		return

	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	var map_node := current_scene.get_node_or_null("map")
	if map_node == null or not _all_regions_open(map_node):
		return

	var upgrade_ui := get_tree().get_first_node_in_group("upgrade_ui")
	if upgrade_ui == null:
		return

	var upgrade_database = upgrade_ui.get("upgrade_database")
	if upgrade_database == null or not _all_palm_trees_bought(upgrade_database):
		return

	_show_victory()

func _all_regions_open(map_node: Node) -> bool:
	# Menang hanya mungkin di tier terakhir (Provinsi).
	if Point.tipe_wilayah_terbuka != 0:
		return false

	var regions = map_node.get("daftar_wilayah")
	if not regions is Array:
		return false

	var valid_regions := 0
	for wilayah in regions:
		if not is_instance_valid(wilayah):
			continue

		var data_wilayah = wilayah.get("data")
		# Beberapa node template di map memang tidak memiliki Resource Wilayah.
		if data_wilayah == null:
			continue

		valid_regions += 1
		if not data_wilayah.terbuka_default:
			return false

	return valid_regions > 0

func _all_palm_trees_bought(upgrade_database) -> bool:
	var found_palm_upgrade := false

	for upgrade_data in upgrade_database.upgrades:
		if upgrade_data == null:
			continue

		if upgrade_data.upgrade_name == "Jumlah Sawit" or upgrade_data.upgrade_name == "Pohon Sawit":
			found_palm_upgrade = true
			if not upgrade_data.is_max_level():
				return false

	return found_palm_upgrade

func _show_victory() -> void:
	_win_shown = true
	SaveManager.save_game()
	get_tree().paused = true
	show()
	_animate_open()

func _animate_open() -> void:
	panel.pivot_offset = panel.size / 2.0
	panel.scale = Vector2(0.7, 0.7)
	panel.modulate = Color(1, 1, 1, 0)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate", Color.WHITE, 0.2)

func _on_continue_pressed() -> void:
	_animate_button_click(continue_button)
	AudioManager.play_sfx()
	await get_tree().create_timer(0.15, true).timeout
	get_tree().paused = false
	hide()

func _on_main_menu_pressed() -> void:
	_animate_button_click(main_menu_button)
	AudioManager.play_sfx()
	SaveManager.save_game()
	await get_tree().create_timer(0.15, true).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/MainMenui.tscn")

func _animate_button_click(button: Button) -> void:
	button.pivot_offset = button.size / 2.0
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.07)
	tween.tween_property(button, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
