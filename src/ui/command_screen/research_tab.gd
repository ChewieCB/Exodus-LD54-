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
	
func chose_an_upgrade(upgrade_id: EnumAutoload.UpgradeId):
	if upgrade_id in ResourceManager.current_upgrades:
		return
	selected_upgrade_id = upgrade_id
	upgrade_button.visible = true

func update_status_all_upgrade_buttons():
	var tech_tree = get_node("TechTree")
	for child in tech_tree.get_children():
		if child is TechUpgradeButton:
			child.update_status()


func _on_upgrade_button_pressed() -> void:
	if selected_upgrade_id != EnumAutoload.UpgradeId.NONE:
		# TODO: Add upgrade cost here
		ResourceManager.current_upgrades.append(selected_upgrade_id)
	update_status_all_upgrade_buttons()
	upgrade_button.visible = false

