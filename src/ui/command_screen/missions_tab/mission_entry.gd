extends MarginContainer

# TODO - create a Mission resource to store a Character, Events, etc.
# @onready var mission: Mission:
#	set(value):
#		mission = value
#		var character = mission.character
#		portrait.texture = character.texture
#		name_label.text = character.name
#		quest_description = mission.description
#		var star_system = mission.star_system
#		star_label.text = star_system.name
#		current_status = mission.status

@onready var current_status: STATUS = STATUS.Available:
	set(value):
		current_status = value
		_update_panels(STATUS_COLOR[current_status])
		status_label.text = STATUS.keys()[current_status]
		# Update the context button based on the state
		match current_status:
			STATUS.Available:
				context_icon.texture = available_icon
				context_button.disabled = true
			STATUS.Active:
				context_icon.texture = cancel_icon
				context_button.disabled = false
			STATUS.Completed:
				context_icon.texture = complete_icon
				context_button.disabled = true
			STATUS.Negated:
				context_icon.texture = negated_icon
				context_button.disabled = true
			_:
				context_icon.texture = info_icon
				context_button.disabled = true

enum STATUS {
	Unavailable, # Player doesn't have the required specialist, research, etc.
	Available, # Player can accept or ignore mission
	Active, # Player has accepted and is currently on mission
	Failed, # Failure condition of mission hit
	Resigned, # Player has cancelled the mission 
	Completed, # Player has finished mission
	Negated # Source of mission consumed by negation zone
}
const STATUS_COLOR: Array[Color] = [ 
	Color.WEB_GRAY,
	Color.DARK_ORANGE,
	Color.STEEL_BLUE,
	Color.RED,
	Color.INDIAN_RED,
	Color.LIME_GREEN,
	Color.BLACK
]

# Panels to recolour
@onready var lower_panel = $PanelContainer/LowerPanelContainer/LowerPanel
@onready var portrait_panel = $PanelContainer/MissionPanelElements/MissionSelectContainer/Details/PortraitContainer/Panel
@onready var status_panel = $PanelContainer/MissionPanelElements/MissionSelectContainer/Details/MissionDetailsContainer/VBoxContainer/MarginContainer3/Panel
# Elements changed by mission data
@onready var portrait = $PanelContainer/MissionPanelElements/MissionSelectContainer/Details/PortraitContainer/MarginContainer/TextureRect
@onready var name_label = $PanelContainer/MissionPanelElements/MissionSelectContainer/Details/MissionDetailsContainer/VBoxContainer/MarginContainer/Label
@onready var quest_description = $PanelContainer/MissionPanelElements/MissionSelectContainer/Details/MissionDetailsContainer/VBoxContainer/MarginContainer2/Label
@onready var status_label = $PanelContainer/MissionPanelElements/MissionSelectContainer/Details/MissionDetailsContainer/VBoxContainer/MarginContainer3/MarginContainer/Label
#@onready var star_image = $PanelContainer/MissionPanelElements/StarContainer/CenterContainer/VBoxContainer/StarOrange
@onready var star_label = $PanelContainer/MissionPanelElements/StarContainer/MarginContainer/CenterContainer/VBoxContainer/Label
# Buttons
@onready var mission_button = $PanelContainer/MissionPanelElements/MissionSelectContainer/Button
@onready var star_button = $PanelContainer/MissionPanelElements/StarContainer/Button
@onready var context_icon = $PanelContainer/MissionPanelElements/CancelContainer/CenterContainer/TextureRect
@onready var context_button = $PanelContainer/MissionPanelElements/CancelContainer/CenterContainer/TextureRect/TextureButton
# Context based cancel button icons
@onready var info_icon = load("res://assets/ui/icons/16/Icon_Help.png")
@onready var cancel_icon = load("res://assets/ui/icons/16/Icon_Close2.png")
@onready var complete_icon = load("res://assets/ui/icons/16/Icon_Confirm1.png")
@onready var available_icon = load("res://assets/ui/icons/16/Icon_Star.png")
@onready var negated_icon = load("res://assets/ui/icons/16/Icon_StarEmpty.png")

func _ready():
	_update_panels(STATUS_COLOR[current_status])
	status_label.text = STATUS.keys()[current_status]


func _update_panels(panel_colour: Color):
	# Set each panel to colour matching the current status
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color =  panel_colour
	for _panel in [lower_panel, portrait_panel, status_panel]:
		_panel.add_theme_stylebox_override ("panel", panel_style)


func _on_context_button_pressed():
	match current_status:
		STATUS.Active:
			current_status = STATUS.Resigned


func _on_mission_button_pressed():
	# TODO - open the relevent event screen dialog
	# For now we just mark the mission active, in future this will be done
	# via the dialog callbacks
	match current_status:
		STATUS.Available:
			current_status = STATUS.Active

