extends Control

@export_category("Upgrade Resources")
@export var upgrade_database: UpgradeDatabase
@export var upgrade_button_scene: PackedScene

@onready var upgrade_container: VBoxContainer = (
	$ScrollContainer/VBoxContainer
)
@onready var desc_panel: PanelContainer = $"../CenterContainer/Desc"
@onready var desc_label: RichTextLabel = $"../CenterContainer/Desc/MarginContainer/RichTextLabel"


func _ready() -> void:
	add_to_group("upgrade_ui")
	if desc_panel:
		desc_panel.hide()
	if upgrade_database:
		SaveManager.load_upgrades(upgrade_database)
		Point.recalculate_stats(upgrade_database.upgrades)
	generate_upgrade_buttons()
	# Tunggu sebentar sampai Map 100% termuat
	await get_tree().create_timer(0.2).timeout
	var map = get_tree().current_scene.get_node_or_null("map")
	if map:
		if map.has_method("get_current_max_capacity"):
			_on_max_capacity_changed(map.get_current_max_capacity())
			
	if upgrade_database and map:
		for u in upgrade_database.upgrades:
			if u and (u.upgrade_name == "Jumlah Sawit" or u.upgrade_name == "Pohon Sawit"):
				for i in range(u.current_level): map.spawn_pohon(true)
			elif u and u.upgrade_name == "Rekrut":
				for i in range(u.current_level): map.spawn_buruh(true)


func generate_upgrade_buttons() -> void:
	clear_upgrade_buttons()

	if upgrade_database == null:
		push_error("Upgrade Database belum dipasang.")
		return

	if upgrade_button_scene == null:
		push_error("Upgrade Button Scene belum dipasang.")
		return

	for upgrade_data: UpgradeData in upgrade_database.upgrades:
		if upgrade_data == null or not upgrade_data.is_unlocked():
			continue

		var button: UpgradeButton = upgrade_button_scene.instantiate()

		upgrade_container.add_child(button)
		button.setup(upgrade_data)

		button.purchase_requested.connect(
			_on_purchase_requested
		)
		button.mouse_entered.connect(func():
			if desc_label and desc_panel:
				desc_label.text = upgrade_data.description
				desc_panel.show()
		)
		button.mouse_exited.connect(func():
			if desc_panel:
				desc_panel.hide()
		)


func clear_upgrade_buttons() -> void:
	for child: Node in upgrade_container.get_children():
		child.queue_free()


func _on_purchase_requested(
	upgrade_data: UpgradeData,
	button: UpgradeButton
) -> void:
	if upgrade_data.is_max_level():
		return

	var current_price = upgrade_data.get_discounted_price()
	if Point.point < current_price:
		#print("Poin Sawit tidak cukup! Butuh: ", current_price, " | Poin sekarang: ", Point.point)
		return

	var max_buys = 1
	if Input.is_key_pressed(KEY_CTRL):
		max_buys = 9999

	var bought = 0
	while not upgrade_data.is_max_level() and Point.point >= upgrade_data.get_discounted_price() and bought < max_buys:
		Point.remove_point(upgrade_data.get_discounted_price())
		upgrade_data.upgrade()
		bought += 1

	if bought == 0:
		return

	button.refresh()
	var total_unlocked := 0
	for u in upgrade_database.upgrades: if u and u.is_unlocked(): total_unlocked += 1
	if total_unlocked != upgrade_container.get_child_count(): generate_upgrade_buttons()
	
	var map = get_tree().current_scene.get_node_or_null("map")
	if map:
		for i in bought:
			if upgrade_data.upgrade_name == "Jumlah Sawit" or upgrade_data.upgrade_name == "Pohon Sawit": map.spawn_pohon()
			if upgrade_data.upgrade_name == "Rekrut": map.spawn_buruh()
			
	# Hitung ulang seluruh stats efek pasca upgrade!
	Point.recalculate_stats(upgrade_database.upgrades)
	SaveManager.save_upgrades(upgrade_database)
	Point.check_missions()
	SaveManager.save_game()

func _on_max_capacity_changed(new_max: int) -> void:
	if upgrade_database == null: return
	for u in upgrade_database.upgrades:
		if u and (u.upgrade_name == "Jumlah Sawit" or u.upgrade_name == "Pohon Sawit" or u.upgrade_name == "Rekrut"):
			u.max_level = new_max
	
	# Reload display buttons to reflect new max level
	generate_upgrade_buttons()
