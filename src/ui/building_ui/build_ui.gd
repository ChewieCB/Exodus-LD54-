extends Control

var active_buttons: Array
# Follows the EnumAutoload.BuildingType enum of:
# NONE, FOOD, WATER, AIR, METAL, HABITATION, CRYO_POD, STORAGE, SECTOR
@onready var button_containers = [
	null, # NONE
	$MarginContainer2/TabContainer/Production/TabContainer/Food/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer,
	$MarginContainer2/TabContainer/Production/TabContainer/Water/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer,
	$MarginContainer2/TabContainer/Production/TabContainer/Air/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer,
	$MarginContainer2/TabContainer/Production/TabContainer/Metal/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer,
	$MarginContainer2/TabContainer/Facility/TabContainer/Habitation/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer,
	null, # CRYO_POD
	$MarginContainer2/TabContainer/Facility/TabContainer/Storage/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer,
	null, # SECTOR
#	$MarginContainer2/TabContainer/Misc/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer
] 
@onready var tab_container = $MarginContainer2/TabContainer
@onready var facility_tab = $MarginContainer2/TabContainer/Facility
@onready var facility_tabs_container = $MarginContainer2/TabContainer/Facility/TabContainer
@onready var production_tab = $MarginContainer2/TabContainer/Facility/TabContainer/Storage
@onready var production_tabs_container = $MarginContainer2/TabContainer/Production/TabContainer


func _ready():
	# Populate the active buttons array with the starting buttons
	for container in button_containers:
		if container:
			active_buttons += container.get_children()
	# If we add or remove any button nodes, update our active button list
	child_entered_tree.connect(_add_button)
	child_exiting_tree.connect(_remove_button)
	# Connect to event manager signals
	EventManager.focus_build_buttons.connect(tutorial_focus_buttons)
	EventManager.unlock_build_buttons.connect(set_buttons_state)


func tutorial_focus_buttons(tab: EnumAutoload.BuildingType, button_indexes: Array=[]):
	# Disable all buttons that aren't the type we want
	var _exceptions = button_containers[tab].get_children()
	if button_indexes:
		for idx in _exceptions.size() - 1:
			if idx not in button_indexes:
				_exceptions.remove_at(idx)
	set_buttons_state(true, _exceptions)
	# Make the specified tab active
	var active_parent_tab = tab_container.get_current_tab_control()
	match tab:
		EnumAutoload.BuildingType.FOOD, EnumAutoload.BuildingType.WATER, EnumAutoload.BuildingType.AIR, EnumAutoload.BuildingType.METAL:
			tab_container.current_tab = 1
			# Offset from the first enum value being 0
			production_tabs_container.current_tab = tab - 1
		EnumAutoload.BuildingType.HABITATION, EnumAutoload.BuildingType.STORAGE:
			tab_container.current_tab = 0
			match tab:
				EnumAutoload.BuildingType.HABITATION:
					facility_tabs_container.current_tab = 0
				EnumAutoload.BuildingType.STORAGE:
					facility_tabs_container.current_tab = 1


func set_buttons_state(is_disabled: bool=false, exceptions: Array=[]) -> void:
	for _button in active_buttons:
		if _button in exceptions:
			_button.disabled = !is_disabled
		else:
			_button.disabled = is_disabled


func _add_button(button: Node):
	if button is BuildingButton:
		active_buttons.append(button)


func _remove_button(button: Node):
	if button is BuildingButton:
		active_buttons.erase(button)


func _on_tab_container_tab_clicked(tab):
	SoundManager.play_button_click_sfx()

