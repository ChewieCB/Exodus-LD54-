extends TabBar
class_name ResearchTab

@onready var upgrade_desc_label: RichTextLabel = $ResearchGraphView/UpgradeDescription
@onready var cost_label: RichTextLabel = $ResearchGraphView/CostLabel
@onready var upgrade_button: Button = $ResearchGraphView/UpgradeButton
@onready var choose_tech_view = $ChooseTech
@onready var research_graph_view = $ResearchGraphView
@onready var research_graph_holder = $ResearchGraphView/ResearchGraphHolder
@onready var not_enough_resource_timer: Timer = $NotEnoughResourceTimer

var warning_click_sfx = preload("res://assets/audio/sfx/Cant_Place_Building_There.mp3")
var proceed_click_sfx = preload("res://assets/audio/sfx/Building_Start.mp3")

var selected_upgrade_data: TechUpgradeButton
var researching_upgrade: TechUpgradeButton
var cost_label_prev_text = ""

func _ready() -> void:
	TickManager.tick.connect(_on_tick)

func _on_tick():
	if researching_upgrade == null:
		return

	if researching_upgrade.research_time_left <= 1:
		ResourceManager.add_upgrade(researching_upgrade.upgrade_id, researching_upgrade.upgrade_name)
		researching_upgrade = null
		update_status_all_upgrade_buttons()
	else:
		researching_upgrade.research_time_left -= 1

func reset_stuff_on_tab() -> void:
	upgrade_desc_label.text = ""
	cost_label.text = ""
	selected_upgrade_data = null
	upgrade_button.visible = false
	update_status_all_upgrade_buttons()
	research_graph_view.visible = false
	choose_tech_view.visible = true
	update_all_specialist_research_graph_buttons()

func select_an_upgrade(upgrade_data: TechUpgradeButton):
	SoundManager.play_button_click_sfx()
	not_enough_resource_timer.stop()
	upgrade_desc_label.text = "[u]{upgrade_name}[/u] - {time} day(s)\n[font_size=12]{upgrade_description}[/font_size]".format(
		{"upgrade_name": upgrade_data.upgrade_name, "upgrade_description": upgrade_data.upgrade_description, "time": upgrade_data.research_time})

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
	var have_previous_upgrade = upgrade_data.check_for_previous_upgrade()
	if not have_previous_upgrade:
		_cancel_select_upgrade()
		return

	selected_upgrade_data = upgrade_data
	upgrade_button.visible = true
	upgrade_button.text = "Proceed"
	cost_label.text = "[center]Cost: "
	if upgrade_data.cost.food > 0:
		cost_label.text += str(upgrade_data.cost.food) + " Food, "
	if upgrade_data.cost.water > 0:
		cost_label.text += str(upgrade_data.cost.water) + " Water, "
	if upgrade_data.cost.air > 0:
		cost_label.text += str(upgrade_data.cost.air) + " Air, "
	if upgrade_data.cost.metal > 0:
		cost_label.text += str(upgrade_data.cost.metal) + " Metal "
	cost_label.text += "[/center]"
	cost_label_prev_text = cost_label.text

	# If click on researching upgrade
	if upgrade_data.is_researching:
		if researching_upgrade == upgrade_data:
			cost_label.text = "[center]Researching... {0} days(s) left[/center]".format([researching_upgrade.research_time_left])
			upgrade_button.visible = false
		else:
			cost_label.text = "[center]Research paused. {0} days(s) left[/center]".format([researching_upgrade.research_time_left])


func _cancel_select_upgrade():
	selected_upgrade_data = null
	upgrade_button.visible = false
	cost_label.text = ""

func update_status_all_upgrade_buttons():
	var research_graph = get_node("ResearchGraphView/ResearchGraphHolder").get_child(0)
	for child in research_graph.get_children():
		if child is TechUpgradeButton:
			child.update_status()

func _on_upgrade_button_pressed() -> void:
	if selected_upgrade_data != null:
		if ResourceManager.check_if_enough_resource(selected_upgrade_data.cost):
			SoundManager.play_sound(proceed_click_sfx, "UI")
			if researching_upgrade != null:
				researching_upgrade.pause_research()
			researching_upgrade = selected_upgrade_data
			if not researching_upgrade.is_researching:
				ResourceManager.change_resource(selected_upgrade_data.cost, false)
			researching_upgrade.start_research()
			# Refresh UI
			for upgr in selected_upgrade_data.conflict_one_of_these_upgrades:
				upgr.disabled = true
			update_status_all_upgrade_buttons()
			upgrade_button.visible = false
			cost_label.text = ""
		else:
			SoundManager.play_sound(warning_click_sfx, "UI")
			cost_label.text = "[center][color=red]Not enough resource[/color][/center]"
			not_enough_resource_timer.start()

func open_research_graph(reseach_scene: PackedScene):
	# This is for select a research category at the research tab main menu
	SoundManager.play_button_click_sfx()
	if reseach_scene == null:
		return
	for child in research_graph_holder.get_children():
		child.queue_free()
	var new_research_scene = reseach_scene.instantiate()
	research_graph_holder.add_child(new_research_scene)
	choose_tech_view.visible = false
	research_graph_view.visible = true


func _on_back_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	research_graph_view.visible = false
	choose_tech_view.visible = true
	reset_stuff_on_tab()


func update_all_specialist_research_graph_buttons():
	for child in choose_tech_view.get_node("SpecialistResearch").get_children():
		var research_button = child as SelectResearchGraphButton
		if research_button.required_officer in ResourceManager.current_officers:
			research_button.disabled = false
			research_button.text = research_button.original_button_text
		else:
			research_button.disabled = true
			research_button.text = "????????"


func _on_not_enough_resource_timer_timeout() -> void:
	cost_label.text = cost_label_prev_text
