extends Control

@onready var alert_container = $VBoxContainer
@onready var alert_scene = preload("res://src/ui/main_screen/alerts/AlertContainer.tscn")

var food_alert: Alert
var water_alert: Alert
var air_alert: Alert
#@onready var food_alert = $VBoxContainer/FoodAlertContainer
#@onready var food_alert_counter = $VBoxContainer/FoodAlertContainer/VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/CountdownContainer/Countdown
#@onready var water_alert = $VBoxContainer/WaterAlertContainer
#@onready var water_alert_counter = $VBoxContainer/WaterAlertContainer/VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/CountdownContainer/Countdown
#@onready var air_alert = $VBoxContainer/AirAlertContainer
#@onready var air_alert_counter = $VBoxContainer/AirAlertContainer/VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/CountdownContainer/Countdown

@onready var resource_low_1_sfx = preload("res://assets/audio/sfx/Resource_Low_1.mp3")

func _ready():
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
		if not food_alert:
			# Create a food alert with countdown
			var new_alert = alert_scene.instantiate()
			var text = "Days Until Starvation"
			
			# Add it to the container
			alert_container.add_child(new_alert)
			new_alert.visible = false
			new_alert.alert_text = text
			new_alert.type = Alert.TYPE.FOOD
			new_alert.has_countdown = true
			new_alert.countdown_value = ticks_left
			
			# Move it to the top so more recent events show at the top
			alert_container.move_child(new_alert, 0)
			new_alert.visible = true
			new_alert.anim_player.play("alert_in")
			await new_alert.anim_player.animation_finished
			#
			food_alert = new_alert
			SoundManager.play_sound(resource_low_1_sfx, "SFX")
		
		# Update the countdown
		food_alert.countdown_value = ticks_left
	else:
		if is_instance_valid(food_alert):
			# Delete it after a time period
			food_alert.anim_player.play("alert_out")
			await food_alert.anim_player.animation_finished
			food_alert.queue_free()


func _dehydrated(ticks_left):
	if ResourceManager.is_thirsty:
		if not water_alert:
			# Create a food alert with countdown
			var new_alert = alert_scene.instantiate()
			var text = "Days Until Dehydration"
			
			# Add it to the container
			alert_container.add_child(new_alert)
			new_alert.visible = false
			new_alert.alert_text = text
			new_alert.type = Alert.TYPE.WATER
			new_alert.has_countdown = true
			new_alert.countdown_value = ticks_left
			
			# Move it to the top so more recent events show at the top
			alert_container.move_child(new_alert, 0)
			new_alert.visible = true
			new_alert.anim_player.play("alert_in")
			await new_alert.anim_player.animation_finished
			#
			water_alert = new_alert
			SoundManager.play_sound(resource_low_1_sfx, "SFX")
		
		# Update the countdown
		water_alert.countdown_value = ticks_left
	else:
		if is_instance_valid(water_alert):
			# Delete it after a time period
			water_alert.anim_player.play("alert_out")
			await water_alert.anim_player.animation_finished
			water_alert.queue_free()


func _suffocating(ticks_left):
	if ResourceManager.is_suffocating:
		if not air_alert:
			# Create a food alert with countdown
			var new_alert = alert_scene.instantiate()
			var text = "Days Until Suffocation"
			
			# Add it to the container
			alert_container.add_child(new_alert)
			new_alert.visible = false
			new_alert.alert_text = text
			new_alert.type = Alert.TYPE.AIR
			new_alert.has_countdown = true
			new_alert.countdown_value = ticks_left
			
			# Move it to the top so more recent events show at the top
			alert_container.move_child(new_alert, 0)
			new_alert.visible = true
			new_alert.anim_player.play("alert_in")
			await new_alert.anim_player.animation_finished
			#
			air_alert = new_alert
			SoundManager.play_sound(resource_low_1_sfx, "SFX")
		
		# Update the countdown
		air_alert.countdown_value = ticks_left
	else:
		if is_instance_valid(air_alert):
			# Delete it after a time period
			air_alert.anim_player.play("alert_out")
			await air_alert.anim_player.animation_finished
			air_alert.queue_free()


func _hide_all(resource):
	for _alert in [food_alert, water_alert, air_alert]:
		if is_instance_valid(_alert):
			_alert.anim_player.play("alert_out")
			await _alert.anim_player.animation_finished
			_alert.queue_free()

