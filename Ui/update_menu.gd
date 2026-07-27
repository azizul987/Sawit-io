extends Control

@export_category("Upgrade Resources")
@export var upgrade_database: UpgradeDatabase
@export var upgrade_button_scene: PackedScene

@export_category("Player")
@export var player_money: float = 1000.0

@onready var upgrade_container: VBoxContainer = (
	$ScrollContainer/VBoxContainer
)

	
func _ready() -> void:
	generate_upgrade_buttons()


func generate_upgrade_buttons() -> void:
	clear_upgrade_buttons()

	if upgrade_database == null:
		push_error("Upgrade Database belum dipasang.")
		return

	if upgrade_button_scene == null:
		push_error("Upgrade Button Scene belum dipasang.")
		return

	for upgrade_data: UpgradeData in upgrade_database.upgrades:
		if upgrade_data == null:
			continue

		var button: UpgradeButton = upgrade_button_scene.instantiate()

		upgrade_container.add_child(button)
		button.setup(upgrade_data)

		button.purchase_requested.connect(
			_on_purchase_requested
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

	if player_money < upgrade_data.price:
		print("Uang tidak cukup.")
		return

	player_money -= upgrade_data.price

	var upgrade_success: bool = upgrade_data.upgrade()

	if not upgrade_success:
		return

	button.refresh()

	print(
		"Membeli ",
		upgrade_data.upgrade_name,
		" | Level: ",
		upgrade_data.current_level,
		"/",
		upgrade_data.max_level,
		" | Sisa uang: ",
		player_money
	)
