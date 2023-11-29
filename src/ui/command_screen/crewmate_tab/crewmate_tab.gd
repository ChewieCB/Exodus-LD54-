extends TabBar
class_name CrewmateTab

@onready var portrait: TextureRect = $Portrait
@onready var basic_info: RichTextLabel = $BasicInfo
@onready var random_thought: RichTextLabel = $RandomThoughtContainer/RandomThought
@onready var button_container = $ScrollContainer/VBoxContainer

@export var crewmate_button: PackedScene

var do_update_thoughts = false

func _ready() -> void:
	TickManager.tick.connect(func (): do_update_thoughts = true)


func reset_stuff_on_tab() -> void:
	portrait.visible = false
	basic_info.text = ""
	random_thought.text = ""
	refresh_button_list()
	if do_update_thoughts:
		CrewmateManager.update_random_thoughts()
		do_update_thoughts = false


func show_crewmate_data(crewmate_data: CrewmateData):
	portrait.visible = true
	if crewmate_data.portrait:
		portrait.texture = crewmate_data.portrait
	var status_text = ""
	var status_color = ""
	match crewmate_data.status:
		EnumAutoload.CrewmateStatus.HEALTHY:
			status_text = "Healthy"
			status_color = "green"
		EnumAutoload.CrewmateStatus.INFECTED:
			status_text = "Infected"
			status_color = "yellow"
		EnumAutoload.CrewmateStatus.INJURED:
			status_text = "Injured"
			status_color = "orange"
		EnumAutoload.CrewmateStatus.CRITICAL:
			status_text = "Critial"
			status_color = "red"
	basic_info.text = "[u]Name: {name}[/u]\nAge: {age}\nJoined date: {date}\nStatus: [color={status_color}]{status_text}[/color]".format(
		{"name": crewmate_data.crewmate_name, "age": crewmate_data.age, "date": crewmate_data.joined_date, 
		"status_color": status_color, "status_text": status_text})
	random_thought.text = "[center]" + crewmate_data.random_thought + "[/center]"


func refresh_button_list():
	for child in button_container.get_children():
		child.queue_free()
	
	for i in range(len(CrewmateManager.current_crewmates)):
		var cb = crewmate_button.instantiate()
		button_container.add_child(cb)
		cb.crewmate_data = CrewmateManager.current_crewmates[i]
		cb.crewmate_tab = self
		cb.update_label()