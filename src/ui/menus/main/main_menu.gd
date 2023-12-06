extends Control

@onready var setting_menu = $SettingMenu
@onready var planet_logo: Sprite2D = $PlanetLogo

@export var scene_after_start: PackedScene
@export var planet_images: Array[Texture2D]

var started = false

func _ready():
	var i = randi_range(0, len(planet_images) - 1)
	planet_logo.texture = planet_images[i]
	var music = load("res://assets/audio/music/ld54-bgm-medley-no-alarms-1.1.mp3")
	SoundManager.play_music(music, 0.2, "Music")
	ScreenTransitionManager.fade_in(0.8)
	await ScreenTransitionManager.transitioned

func _on_settings_button_pressed():
	SoundManager.play_button_click_sfx()
	setting_menu.visible = !setting_menu.visible


func _on_quit_button_pressed():
	SoundManager.play_button_click_sfx()
	ScreenTransitionManager.fade_out(0.8)
	await ScreenTransitionManager.transitioned
	get_tree().quit()


func _on_start_button_pressed():
	SoundManager.play_button_click_sfx()
	if started:
		return
	started = true
	ScreenTransitionManager.fade_out(0.8)
	await ScreenTransitionManager.transitioned
	get_tree().change_scene_to_packed(scene_after_start)
