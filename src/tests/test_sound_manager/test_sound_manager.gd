@tool
extends Node2D

@export var sfx_stream: AudioStream
@export var music_streams: Array[AudioStream]
var music_index = 0
var last_played_music_index = -1

@onready var play_music = $UI/Control/MarginContainer/VBoxContainer/PlayMusicButton
@onready var now_playing_container = $UI/Control/MarginContainer2
@onready var now_playing_label = $UI/Control/MarginContainer2/PanelContainer/MarginContainer/NowPlaying
@onready var stop_music = $UI/Control/MarginContainer/VBoxContainer/StopMusicButton
@onready var prev_track = $UI/Control/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/CenterContainer/PrevButton
@onready var next_track = $UI/Control/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/CenterContainer2/NextButton
@onready var play_sfx = $UI/Control/MarginContainer/VBoxContainer/PlaySFXButtom
@onready var play_sfx_pool = $UI/Control/MarginContainer/VBoxContainer/PlaySFXPoolButton
@onready var music_volume_slider = $UI/Control/MarginContainer/VBoxContainer/MusicVolumeSlider
@onready var sfx_volume_slider = $UI/Control/MarginContainer/VBoxContainer/SFXVolumeSlider

@onready var sfx_pool = $SoundPool


func _ready():
	music_volume_slider.value = SoundManager.get_music_volume() * 100
	sfx_volume_slider.value = SoundManager.get_sound_volume() * 100
	ScreenTransitionManager.fade_in(0.8)
	await ScreenTransitionManager.transitioned


func _on_play_music_button_pressed():
	var music = music_streams[music_index]
	SoundManager.play_music(music, 0.2, "Music")
	
	if not now_playing_container.visible:
		now_playing_label.text = "Now playing: %s - %s" % [music_index + 1, music.resource_path.get_file().get_basename()]
		now_playing_container.visible = true
	
	if prev_track.disabled and next_track.disabled:
		prev_track.disabled = false
		next_track.disabled = false


func _on_prev_button_pressed():
	music_index -= 1
	if music_index < 0:
		music_index = music_streams.size() - 1
	
	var music = music_streams[music_index]
	SoundManager.play_music(music, 0.2, "Music")
	now_playing_label.text = "Now playing: %s - %s" % [music_index + 1, music.resource_path.get_file().get_basename()]


func _on_next_button_pressed():
	music_index += 1
	music_index %= music_streams.size()
	
	var music = music_streams[music_index]
	SoundManager.play_music(music, 0.2, "Music")
	now_playing_label.text = "Now playing: %s - %s" % [music_index + 1, music.resource_path.get_file().get_basename()]


func _on_stop_music_button_pressed():
	SoundManager.stop_music(0.4)
	
	if now_playing_container.visible:
		now_playing_container.visible = false
	
	if not prev_track.disabled and not next_track.disabled:
		prev_track.disabled = true
		next_track.disabled = true


func _on_play_sfx_buttom_pressed():
	SoundManager.play_sound(sfx_stream, "SFX")


func _on_play_sfx_pool_button_pressed():
	sfx_pool.play_random_sound()


func _on_music_volume_slider_value_changed(value):
	SoundManager.set_music_volume(value / 100)


func _on_sfx_volume_slider_value_changed(value):
	SoundManager.set_sound_volume(value / 100)


func _on_menu_button_pressed():
	ScreenTransitionManager.fade_out(0.8)
	await ScreenTransitionManager.transitioned
	get_tree().change_scene_to_file("res://src/ui/menus/main/MainMenu.tscn")
