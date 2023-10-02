extends Control

@onready var hab_buttons_container = $MarginContainer2/TabContainer/Habitation/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer
@onready var farm_buttons_container = $MarginContainer2/TabContainer/Food/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer
@onready var water_butttons_container = $MarginContainer2/TabContainer/Water/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer
@onready var air_buttons_container = $MarginContainer2/TabContainer/Food/MarginContainer/ScrollContainer/MarginContainer/VBoxContainer

var button_click_sfx = preload("res://assets/audio/sfx/ui_click_1.mp3")


func update_available_buildings():
	pass


func _on_hab_1_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	BuildingManager._build_hab_1()


func _on_hab_2_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	BuildingManager._build_hab_2()


func _on_hab_3_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	BuildingManager._build_hab_3()


func _on_farm_1_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	BuildingManager._build_farm_1()


func _on_farm_2_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	BuildingManager._build_farm_2()


func _on_farm_3_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	BuildingManager._build_farm_3()


func _on_water_1_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	BuildingManager._build_water_1()


func _on_water_2_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	BuildingManager._build_water_2()


func _on_water_3_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	BuildingManager._build_water_3()


func _on_air_1_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	BuildingManager._build_air_1()


func _on_air_2_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	BuildingManager._build_air_2()


func _on_air_3_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	BuildingManager._build_air_3()


func _on_tab_container_tab_clicked(tab):
	SoundManager.play_sound(button_click_sfx, "UI")
