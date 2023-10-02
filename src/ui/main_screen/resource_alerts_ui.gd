extends Control


@onready var food_alert = $VBoxContainer/FoodAlertContainer
@onready var food_alert_counter = $VBoxContainer/FoodAlertContainer/VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/CountdownContainer/Countdown
@onready var water_alert = $VBoxContainer/WaterAlertContainer
@onready var water_alert_counter = $VBoxContainer/WaterAlertContainer/VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/CountdownContainer/Countdown
@onready var air_alert = $VBoxContainer/AirAlertContainer
@onready var air_alert_counter = $VBoxContainer/AirAlertContainer/VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/CountdownContainer/Countdown

@onready var resource_low_1_sfx = preload("res://assets/audio/sfx/Resource_Low_1.mp3")

func _ready():
	food_alert.visible = false
	water_alert.visible = false
	air_alert.visible = false
	ResourceManager.starving.connect(_starving)
	ResourceManager.dehydrated.connect(_dehydrated)
	ResourceManager.suffocating.connect(_suffocating)
	#
	ResourceManager.stopped_starving.connect(_starving)
	ResourceManager.stopped_thirsty.connect(_dehydrated)
	ResourceManager.stopped_suffocating.connect(_suffocating)
	#
	ResourceManager.game_over.connect(_hide_all)


func _starving(ticks_left):
	if ResourceManager.is_starving:
		if not food_alert.visible:
			food_alert.visible = true
			SoundManager.play_sound(resource_low_1_sfx, "SFX")
		food_alert_counter.text = str(ticks_left)
	else:
		food_alert.visible = false


func _dehydrated(ticks_left):
	if ResourceManager.is_thirsty:
		if not water_alert.visible:
			water_alert.visible = true
			SoundManager.play_sound(resource_low_1_sfx, "SFX")
		water_alert_counter.text = str(ticks_left)
	else:
		water_alert.visible = false


func _suffocating(ticks_left):
	if ResourceManager.is_suffocating:
		if not air_alert.visible:
			air_alert.visible = true
			SoundManager.play_sound(resource_low_1_sfx, "SFX")
		air_alert_counter.text = str(ticks_left)
	else:
		air_alert.visible = false


func _hide_all():
	# TODO - add animations
	food_alert.visible = false
	water_alert.visible = false
	air_alert.visible = false

