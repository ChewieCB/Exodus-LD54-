extends Button
class_name CrewmateButton

var crewmate_data: CrewmateData = null
var crewmate_tab: CrewmateTab = null

func update_label():
	text = crewmate_data.crewmate_name

func _on_pressed() -> void:
	crewmate_tab.show_crewmate_data(crewmate_data)
