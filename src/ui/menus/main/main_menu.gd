extends Control

@onready var anim_player = $AnimationPlayer
@onready var fullscreen_toggle = $SettingsScreen/VBoxContainer/ButtonsContainer/PanelContainer/VBoxContainer/FullscreenContainer/HBoxContainer/CheckButton
@onready var music_volume_slider = $SettingsScreen/VBoxContainer/ButtonsContainer/PanelContainer/VBoxContainer/MusicSliderContainer/HSlider
@onready var sfx_volume_slider = $SettingsScreen/VBoxContainer/ButtonsContainer/PanelContainer/VBoxContainer/SFXSliderContainer/HSlider
@onready var ui_sfx_volume_slider = $SettingsScreen/VBoxContainer/ButtonsContainer/PanelContainer/VBoxContainer/UISliderLabelContainer/HSlider
@export var scene_after_start: PackedScene

var button_click_sfx = preload("res://assets/audio/sfx/ui_click_1.mp3")

var started = false

func _ready():
	music_volume_slider.value = SoundManager.get_music_volume() * 100
	sfx_volume_slider.value = SoundManager.get_sound_volume() * 100
	ui_sfx_volume_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("UI"))
	) * 100
	var music = load("res://assets/audio/music/ld54-bgm-medley-no-alarms-1.1.mp3")
	SoundManager.play_music(music, 0.2, "Music")
	ScreenTransitionManager.fade_in(0.8)
	await ScreenTransitionManager.transitioned


func _on_settings_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	anim_player.play("main_out")
	anim_player.queue("settings_in")


func _on_back_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	anim_player.queue("settings_out")
	anim_player.queue("main_in")


func _on_quit_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	ScreenTransitionManager.fade_out(0.8)
	await ScreenTransitionManager.transitioned
	get_tree().quit()


func _on_start_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	if started:
		return
	started = true
	ScreenTransitionManager.fade_out(0.8)
	await ScreenTransitionManager.transitioned
	get_tree().change_scene_to_packed(scene_after_start)


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
