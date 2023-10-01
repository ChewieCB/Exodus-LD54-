extends MarginContainer

@onready var pause_button = $PanelContainer/HBoxContainer/MarginContainer/HBoxContainer/PauseContainer/Button
@onready var pause_texture = $PanelContainer/HBoxContainer/MarginContainer/HBoxContainer/PauseContainer/TextureRect
@onready var normal_button = $PanelContainer/HBoxContainer/MarginContainer/HBoxContainer/Speed1Container/Button
@onready var normal_texture = $PanelContainer/HBoxContainer/MarginContainer/HBoxContainer/Speed1Container/TextureRect
@onready var fast_button = $PanelContainer/HBoxContainer/MarginContainer/HBoxContainer/Speed2Container/Button
@onready var fast_texture =$PanelContainer/HBoxContainer/MarginContainer/HBoxContainer/Speed2Container/TextureRect


func _on_pause_button_pressed():
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
	fast_button.disabled = true
	fast_texture.modulate = Color.GRAY
	TickManager._set_tick_rate(TickManager.FAST_TICK_SPEED)
	
	if pause_button.disabled:
		pause_button.disabled = false
		pause_texture.modulate = Color.WHITE
		TickManager.start_ticks()
	if fast_button.disabled:
		fast_button.disabled = false
		normal_texture.modulate = Color.WHITE
