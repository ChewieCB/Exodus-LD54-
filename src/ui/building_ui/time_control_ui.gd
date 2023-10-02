extends MarginContainer

@onready var pause_button = $VBoxContainer/PanelContainer2/HBoxContainer/MarginContainer/HBoxContainer/PauseContainer/Button
@onready var pause_texture = $VBoxContainer/PanelContainer2/HBoxContainer/MarginContainer/HBoxContainer/PauseContainer/TextureRect
@onready var normal_button = $VBoxContainer/PanelContainer2/HBoxContainer/MarginContainer/HBoxContainer/Speed1Container/Button
@onready var normal_texture = $VBoxContainer/PanelContainer2/HBoxContainer/MarginContainer/HBoxContainer/Speed1Container/TextureRect
@onready var fast_button = $VBoxContainer/PanelContainer2/HBoxContainer/MarginContainer/HBoxContainer/Speed2Container/Button
@onready var fast_texture =$VBoxContainer/PanelContainer2/HBoxContainer/MarginContainer/HBoxContainer/Speed2Container/TextureRect

@onready var tick_progress_bar = $VBoxContainer/PanelContainer/ProgressBar

@onready var day_counter = $VBoxContainer/PanelContainer3/MarginContainer/DayLabel
@onready var date = $VBoxContainer/PanelContainer3/MarginContainer/DateLabel

var button_click_sfx = preload("res://assets/audio/sfx/ui_click_1.mp3")

var current_day = 0
var start_date_unix = 3873826800
# Unix timestamp works in seconds from 1970, 1 day is 86,400 seconds
const UNIX_DAY = 86400
const MONTH_NAMES = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
var current_timestamp = start_date_unix


func _ready():
	TickManager.tick.connect(_update_day_counter)
	tick_progress_bar.value = 0
	# Set buttons to normal speed configuration
	normal_button.disabled = true
	normal_texture.modulate = Color.WHITE
	pause_button.disabled = false
	pause_texture.modulate = Color.GRAY
	fast_button.disabled = false
	fast_texture.modulate = Color.WHITE


func _physics_process(delta):
	if Input.is_action_just_pressed("set_timescale_0"):
		_on_pause_button_pressed()
	elif Input.is_action_just_pressed("set_timescale_1"):
		_on_speed_1_button_pressed()
	elif Input.is_action_just_pressed("set_timescale_2"): 
		_on_speed_2_button_pressed()
	# Inversely map the time left on tick timer to progress bar value
	# i.e. 5 -> 0 on timer, needs to be 0 -> 100 on progress bar
	var tick_progress = remap(
		TickManager.tick_timer.time_left, 
		TickManager.tick_timer.wait_time, 0, 
		0, 100
	)
	tick_progress = clamp(tick_progress, 0, 100)
	tick_progress_bar.value = tick_progress


func _update_day_counter():
	current_day += 1
	day_counter.text = "Day {0}".format([str(current_day + 1)])
	current_timestamp += UNIX_DAY
	var new_date = Time.get_date_string_from_unix_time(current_timestamp)
	var YMD = new_date.split("-")
	date.text = "{0} {1} {2}".format([YMD[2], MONTH_NAMES[int(YMD[1]) - 1], YMD[0]])


func _on_pause_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	pause_button.disabled = true
	pause_texture.modulate = Color.GRAY
	TickManager.stop_ticks()
	
	if normal_button.disabled:
		normal_button.disabled = false
		normal_texture.modulate = Color.WHITE
	if fast_button.disabled:
		fast_button.disabled = false
		fast_texture.modulate = Color.WHITE


func _on_speed_1_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	normal_button.disabled = true
	normal_texture.modulate = Color.WHITE
	TickManager._set_tick_rate(TickManager.SLOW_TICK_SPEED)
	
	if pause_button.disabled:
		pause_button.disabled = false
		pause_texture.modulate = Color.GRAY
		TickManager.start_ticks()
	if fast_button.disabled:
		fast_button.disabled = false
		fast_texture.modulate = Color.WHITE


func _on_speed_2_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	fast_button.disabled = true
	fast_texture.modulate = Color.GRAY
	TickManager._set_tick_rate(TickManager.FAST_TICK_SPEED)
	
	if pause_button.disabled:
		pause_button.disabled = false
		pause_texture.modulate = Color.WHITE
		TickManager.start_ticks()
	if normal_button.disabled:
		normal_button.disabled = false
		normal_texture.modulate = Color.WHITE

