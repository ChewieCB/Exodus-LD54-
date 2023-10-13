extends Control

@onready var hab_buttons_container = $MarginContainer2/TabContainer/Habitation/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer
@onready var farm_buttons_container = $MarginContainer2/TabContainer/Food/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer
@onready var water_butttons_container = $MarginContainer2/TabContainer/Water/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer
@onready var air_buttons_container = $MarginContainer2/TabContainer/Food/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer


func _on_tab_container_tab_clicked(tab):
	SoundManager.play_button_click_sfx()
