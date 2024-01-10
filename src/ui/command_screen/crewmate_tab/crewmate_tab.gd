extends TabBar
class_name CrewmateTab

@onready var portrait: TextureRect = $Portrait
@onready var basic_info: RichTextLabel = $BasicInfo
@onready var random_thought: RichTextLabel = $RandomThoughtContainer/RandomThought
@onready var button_container = $ScrollContainer/VBoxContainer
@onready var yeet_button: Button = $YeetButton
@onready var confirm_yeet_button: Button = $ConfirmYeetButton

@export var crewmate_button: PackedScene

var do_update_thoughts = false
var selected_crewmate_name = ""
var previous_crewmate_name = ""

func _ready() -> void:
	TickManager.tick.connect(func (): do_update_thoughts = true)
	show_crewmate_data(CrewmateManager.current_crewmates[0])


func reset_stuff_on_tab() -> void:
	portrait.visible = false
	basic_info.text = ""
	random_thought.text = ""
	selected_crewmate_name = ""
	reset_yeet_decision()
	yeet_button.visible = false
	refresh_button_list()
	if do_update_thoughts:
		CrewmateManager.update_random_thoughts()
		do_update_thoughts = false


func show_crewmate_data(crewmate_data: CrewmateData):
	reset_yeet_decision()
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
	selected_crewmate_name = crewmate_data.crewmate_name


func refresh_button_list():
	for child in button_container.get_children():
		child.queue_free()

	for i in range(len(CrewmateManager.current_crewmates)):
		var cb = crewmate_button.instantiate()
		button_container.add_child(cb)
		cb.crewmate_data = CrewmateManager.current_crewmates[i]
		cb.crewmate_tab = self
		cb.update_label()
	
	var first_button = button_container.get_child(0)
	first_button._on_pressed()


func reset_yeet_decision():
	previous_crewmate_name = selected_crewmate_name
	# Reset thought after jettison threat
	if confirm_yeet_button.visible == true:
		for child in button_container.get_children():
			var cb = child as CrewmateButton
			if cb.crewmate_data.crewmate_name == previous_crewmate_name:
				cb.crewmate_data.random_thought = "[color=yellow]...[/color]"
	yeet_button.visible = true
	confirm_yeet_button.visible = false
	if len(CrewmateManager.current_crewmates) <= 1:
		yeet_button.visible = false


func _on_yeet_button_pressed() -> void:
	yeet_button.visible = false
	confirm_yeet_button .visible = true
	CrewmateManager.set_yeet_thought(selected_crewmate_name)
	for child in button_container.get_children():
		var cb = child as CrewmateButton
		if cb.crewmate_data.crewmate_name == selected_crewmate_name:
			random_thought.text = "[color=red][center]" + cb.crewmate_data.random_thought + "[/center][/color]"


func _on_confirm_yeet_button_pressed() -> void:
	CrewmateManager.remove_crewmates_by_name(selected_crewmate_name)
	reset_stuff_on_tab()
