extends Control

@onready var anim_player = $AnimationPlayer
@onready var fullscreen_toggle = $SettingsScreen/VBoxContainer/ButtonsContainer/PanelContainer/VBoxContainer/FullscreenContainer/HBoxContainer/CheckButton
@onready var music_volume_slider = $SettingsScreen/VBoxContainer/ButtonsContainer/PanelContainer/VBoxContainer/MusicSliderContainer/HSlider
@onready var sfx_volume_slider = $SettingsScreen/VBoxContainer/ButtonsContainer/PanelContainer/VBoxContainer/SFXSliderContainer/HSlider


func _ready():
	music_volume_slider.value = SoundManager.get_music_volume() * 100
	sfx_volume_slider.value = SoundManager.get_sound_volume() * 100
	ScreenTransitionManager.fade_in(0.8)
	await ScreenTransitionManager.transitioned


func _on_settings_button_pressed():
	anim_player.play("main_out")
	anim_player.queue("settings_in")


func _on_back_button_pressed():
	anim_player.queue("settings_out")
	anim_player.queue("main_in")


func _on_quit_button_pressed():
	ScreenTransitionManager.fade_out(0.8)
	await ScreenTransitionManager.transitioned
	get_tree().quit()


func _on_button_pressed():
	pass
#	ScreenTransitionManager.fade_out(0.8)
#	await ScreenTransitionManager.transitioned
#	get_tree().change_scene_to_file("res://src/tests/test_sound_manager/TestSoundManager.tscn")


func _on_fullscreen_button_pressed():
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
