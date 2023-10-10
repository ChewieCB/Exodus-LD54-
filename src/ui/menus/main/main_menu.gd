extends Control

@onready var setting_menu = $SettingMenu

@export var scene_after_start: PackedScene


var button_click_sfx = preload("res://assets/audio/sfx/ui_click_1.mp3")

var started = false

func _ready():
	var music = load("res://assets/audio/music/ld54-bgm-medley-no-alarms-1.1.mp3")
	SoundManager.play_music(music, 0.2, "Music")
	ScreenTransitionManager.fade_in(0.8)
	await ScreenTransitionManager.transitioned


func _on_settings_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	setting_menu.visible = true


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