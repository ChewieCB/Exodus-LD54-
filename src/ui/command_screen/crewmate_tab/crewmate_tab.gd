extends TabBar
class_name CrewmateTab

@onready var portrait: TextureRect = $Portrait
@onready var basic_info: RichTextLabel = $BasicInfo
@onready var backstory: Label = $Backstory
@onready var button_container = $ScrollContainer/VBoxContainer

@export var crewmate_button: PackedScene

func reset_stuff_on_tab() -> void:
    portrait.visible = false
    basic_info.text = ""
    backstory.text = ""
    refresh_button_list()


func show_crewmate_data(crewmate_data: CrewmateData):
    portrait.visible = true
    if crewmate_data.portrait:
        portrait.texture = crewmate_data.portrait
    basic_info.text = "Name: {name}\nAge: {age}\nJoined date: {date}".format(
        {"name": crewmate_data.crewmate_name, "age": crewmate_data.age, "date": crewmate_data.joined_date})
    backstory.text = crewmate_data.backstory


func refresh_button_list():
    for child in button_container.get_children():
        child.queue_free()
    
    for i in range(len(CrewmateManager.current_crewmates)):
        var cb = crewmate_button.instantiate()
        button_container.add_child(cb)
        cb.crewmate_data = CrewmateManager.current_crewmates[i]
        cb.crewmate_tab = self
        cb.update_label()