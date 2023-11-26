extends TabBar
class_name ResearchTab

@onready var upgrade_desc_label: RichTextLabel = $TechTree/UpgradeDescription
@onready var upgrade_button: Button = $TechTree/UpgradeButton
var selected_upgrade_id: EnumAutoload.UpgradeId = EnumAutoload.UpgradeId.NONE

func reset_stuff_on_tab() -> void:
	upgrade_desc_label.text = ""
	selected_upgrade_id = EnumAutoload.UpgradeId.NONE
	upgrade_button.visible = false
	update_status_all_upgrade_buttons()
	
func select_an_upgrade(upgrade_data: TechUpgradeButton):
	upgrade_desc_label.text = "[u]{upgrade_name}[/u]\n[font_size=12]{upgrade_description}[/font_size]".format(
		{"upgrade_name": upgrade_data.upgrade_name, "upgrade_description": upgrade_data.upgrade_description})

	# Check if already activated
	if upgrade_data.upgrade_id != EnumAutoload.UpgradeId.NONE and \
		upgrade_data.upgrade_id in ResourceManager.current_upgrades:
		selected_upgrade_id = EnumAutoload.UpgradeId.NONE
		upgrade_button.visible = false
		return

	# Check for prerequisite upgrade
	var have_previous_upgrade = true
	if len(upgrade_data.require_one_of_these_upgrades) > 0:
		have_previous_upgrade = false
		for upgr in upgrade_data.require_one_of_these_upgrades:
			if upgr.activated:
				have_previous_upgrade = true
	if not have_previous_upgrade:
		selected_upgrade_id = EnumAutoload.UpgradeId.NONE
		upgrade_button.visible = false
		return

	selected_upgrade_id = upgrade_data.upgrade_id
	upgrade_button.visible = true

func update_status_all_upgrade_buttons():
	var tech_tree = get_node("TechTree")
	for child in tech_tree.get_children():
		if child is TechUpgradeButton:
			child.update_status()


func _on_upgrade_button_pressed() -> void:
	if selected_upgrade_id != EnumAutoload.UpgradeId.NONE:
		# TODO: Add upgrade cost here. If not enough, return
		ResourceManager.current_upgrades.append(selected_upgrade_id)
	update_status_all_upgrade_buttons()
	upgrade_button.visible = false

