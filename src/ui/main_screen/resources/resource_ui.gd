extends Control

@onready var population_counter = $MarginContainer/HBoxContainer/MarginContainer/HBoxContainer/PopContainer/HBoxContainer/WorkerLabel
@onready var worker_counter = $MarginContainer/HBoxContainer/MarginContainer/HBoxContainer/WorkerContainer/HBoxContainer/PopLabel

@onready var debug_hab = $MarginContainer/HBoxContainer/MarginContainer5/HBoxContainer/HabDebug
@onready var debug_food = $MarginContainer/HBoxContainer/MarginContainer2/HBoxContainer/FoodDebug
@onready var debug_water = $MarginContainer/HBoxContainer/MarginContainer3/HBoxContainer/WaterDebug
@onready var debug_air = $MarginContainer/HBoxContainer/MarginContainer4/HBoxContainer/AirDebug


func _ready():
	ResourceManager.population_changed.connect(_update_pop_ui)
	ResourceManager.workers_changed.connect(_update_worker_ui)
	ResourceManager.housing_changed.connect(_update_housing_ui)
	#
	ResourceManager.food_modifier_changed.connect(_update_debug_food)
	ResourceManager.water_modifier_changed.connect(_update_debug_water)
	ResourceManager.air_modifier_changed.connect(_update_debug_air)
	
	# This is fucking stupid, but it's 1AM, i'm tired, and it fixes the UI update problem
	ResourceManager.population_amount = ResourceManager.population_amount
	ResourceManager.worker_amount = ResourceManager.worker_amount


func animate_bar(bar, value) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(
		bar, "value", value, 0.4
	).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)


func _update_pop_ui(value):
	population_counter.text = str(value)


func _update_worker_ui(value):
	worker_counter.text = str(value)


func _update_housing_ui(total, available):
	debug_hab.text = "{0} ({1})".format([str(total), str(available)])


func _update_debug_food(total, modifier):
	var modifier_str = str(round(modifier))
	var modifier_prefix = ""
	if modifier > 0:
		modifier_prefix = "+" 
	debug_food.text = "{0} ({1}{2})".format([str(round(total)), modifier_prefix, modifier_str])


func _update_debug_water(total, modifier):
	var modifier_str = str(round(modifier))
	var modifier_prefix = ""
	if modifier > 0:
		modifier_prefix = "+" 
	debug_water.text = "{0} ({1}{2})".format([str(round(total)), modifier_prefix, modifier_str])


func _update_debug_air(total, modifier):
	var modifier_str = str(round(modifier))
	var modifier_prefix = ""
	if modifier > 0:
		modifier_prefix = "+" 
	debug_air.text = "{0} ({1}{2})".format([str(round(total)), modifier_prefix, modifier_str])



func _on_worker_ui_mouse_entered():
	ResourceManager.emit_signal("ui_hover_show", "Available Crew members")


func _on_worker_ui_mouse_exited():
	ResourceManager.emit_signal("ui_hover_hide")


func _on_pop_ui_mouse_entered():
	ResourceManager.emit_signal("ui_hover_show", "Total Population")


func _on_pop_ui_mouse_exited():
	ResourceManager.emit_signal("ui_hover_hide")


func _on_hab_ui_mouse_entered():
	ResourceManager.emit_signal("ui_hover_show", "Housing (Available Housing)")


func _on_hab_ui_mouse_exited():
	ResourceManager.emit_signal("ui_hover_hide")


func _on_food_ui_mouse_entered():
	ResourceManager.emit_signal("ui_hover_show", "Food (Food per Day)")


func _on_food_ui_mouse_exited():
	ResourceManager.emit_signal("ui_hover_hide")


func _on_water_ui_mouse_entered():
	ResourceManager.emit_signal("ui_hover_show", "Water (Water per Day)")


func _on_water_ui_mouse_exited():
	ResourceManager.emit_signal("ui_hover_hide")


func _on_air_ui_mouse_entered():
	ResourceManager.emit_signal("ui_hover_show", "Oxygen (Oxygen per Day)")


func _on_air_ui_mouse_exited():
	ResourceManager.emit_signal("ui_hover_hide")
