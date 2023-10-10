extends Control

@onready var fullscreen_toggle = $VBoxContainer/ButtonsContainer/PanelContainer/VBoxContainer/FullscreenContainer/HBoxContainer/CheckButton
@onready var music_volume_slider = $VBoxContainer/ButtonsContainer/PanelContainer/VBoxContainer/MusicSliderContainer/HSlider
@onready var sfx_volume_slider = $VBoxContainer/ButtonsContainer/PanelContainer/VBoxContainer/SFXSliderContainer/HSlider
@onready var ui_sfx_volume_slider = $VBoxContainer/ButtonsContainer/PanelContainer/VBoxContainer/UISliderLabelContainer/HSlider

var button_click_sfx = preload("res://assets/audio/sfx/ui_click_1.mp3")

func _ready() -> void:
	music_volume_slider.value = SoundManager.get_music_volume() * 100
	sfx_volume_slider.value = SoundManager.get_sound_volume() * 100
	ui_sfx_volume_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("UI"))
	) * 100



func _input(event):
	if event.is_action_pressed("setting_menu"):
		SoundManager.play_sound(button_click_sfx, "UI")
		visible = !visible
		

func _on_fullscreen_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	# Checked = Fullscreen, Unchecked = Windowed
	var window_mode
	match fullscreen_toggle.button_pressed:
		true:
			window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
		false:
			window_mode = DisplayServer.WINDOW_MODE_WINDOWED
	
	DisplayServer.window_set_mode(window_mode)


func _on_music_volume_slider_value_changed(value):
	SoundManager.set_music_volume(value / 100)


func _on_sfx_volume_slider_value_changed(value):
	SoundManager.set_sound_volume(value / 100)


func _on_ui_sfx_slider_value_changed(value):
	var volume_between_0_and_1 = remap(value, 0, 100, 0, 1)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("UI"), 
		linear_to_db(volume_between_0_and_1)
	)


func _on_ui_sfx_slider_changed():
	SoundManager.play_sound(button_click_sfx, "UI")


func _on_sfx_slider_changed():
	SoundManager.play_sound(button_click_sfx, "UI")


func _on_music_slider_changed():
	SoundManager.play_sound(button_click_sfx, "UI")


func _on_back_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	visible = false