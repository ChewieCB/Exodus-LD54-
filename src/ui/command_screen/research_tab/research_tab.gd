extends TabBar
class_name ResearchTab

@onready var upgrade_desc_label: RichTextLabel = $ResearchGraphView/UpgradeDescription
@onready var upgrade_button: Button = $ResearchGraphView/UpgradeButton
@onready var choose_tech_view = $ChooseTech
@onready var research_graph_view = $ResearchGraphView
@onready var research_graph_holder = $ResearchGraphView/ResearchGraphHolder

var selected_upgrade_data: TechUpgradeButton

func reset_stuff_on_tab() -> void:
	upgrade_desc_label.text = ""
	selected_upgrade_data = null
	upgrade_button.visible = false
	update_status_all_upgrade_buttons()
	research_graph_view.visible = false
	choose_tech_view.visible = true
	update_all_specialist_research_graph_buttons()

func select_an_upgrade(upgrade_data: TechUpgradeButton):
	upgrade_desc_label.text = "[u]{upgrade_name}[/u]\n[font_size=12]{upgrade_description}[/font_size]".format(
		{"upgrade_name": upgrade_data.upgrade_name, "upgrade_description": upgrade_data.upgrade_description})

	# Check if can be activated
	if upgrade_data.upgrade_id != EnumAutoload.UpgradeId.NONE and \
		upgrade_data.upgrade_id in ResourceManager.current_upgrades:
		_cancel_select_upgrade()
		return
	if upgrade_data.disabled:
		_cancel_select_upgrade()
		return

	# Check for conflicted upgrades
	if len(upgrade_data.conflict_one_of_these_upgrades) > 0:
		for upgr in upgrade_data.conflict_one_of_these_upgrades:
			if upgr.activated:
				_cancel_select_upgrade()
				return

	# Check for prerequisite upgrade
	var have_previous_upgrade = true
	if len(upgrade_data.require_one_of_these_upgrades) > 0:
		have_previous_upgrade = false
		for upgr in upgrade_data.require_one_of_these_upgrades:
			if upgr.activated:
				have_previous_upgrade = true
	if not have_previous_upgrade:
		_cancel_select_upgrade()
		return

	selected_upgrade_data = upgrade_data
	upgrade_button.visible = true


func _cancel_select_upgrade():
	selected_upgrade_data = null
	upgrade_button.visible = false


func update_status_all_upgrade_buttons():
	var research_graph = get_node("ResearchGraphView/ResearchGraphHolder").get_child(0)
	for child in research_graph.get_children():
		if child is TechUpgradeButton:
			child.update_status()


func _on_upgrade_button_pressed() -> void:
	if selected_upgrade_data != null:
		# TODO: Add upgrade cost here. If not enough, return
		ResourceManager.current_upgrades.append(selected_upgrade_data.upgrade_id)
	for upgr in selected_upgrade_data.conflict_one_of_these_upgrades:
		upgr.disabled = true
	update_status_all_upgrade_buttons()
	upgrade_button.visible = false


func open_research_graph(research_name: String):
	var found = false
	for child in research_graph_holder.get_children():
		if child.name == research_name:
			child.visible = true
			found = true
		else:
			child.visible = false
	if found:
		choose_tech_view.visible = false
		research_graph_view.visible = true


func _on_back_button_pressed() -> void:
	research_graph_view.visible = false
	choose_tech_view.visible = true


func update_all_specialist_research_graph_buttons():
	for child in choose_tech_view.get_node("SpecialistResearch").get_children():
		var research_button = child as SelectResearchGraphButton
		if research_button.required_officer in ResourceManager.current_officers:
			research_button.disabled = false
			research_button.text = research_button.original_button_text
		else:
			research_button.disabled = true
			research_button.text = "????????"
