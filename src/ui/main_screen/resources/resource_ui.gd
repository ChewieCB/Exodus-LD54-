extends Control

@onready var population_counter = $MarginContainer/HBoxContainer/MarginContainer/HBoxContainer/WorkerContainer/HBoxContainer/WorkerLabel
@onready var worker_counter = $MarginContainer/HBoxContainer/MarginContainer/HBoxContainer/PopContainer/HBoxContainer/PopLabel

@onready var debug_hab = $MarginContainer/HBoxContainer/MarginContainer5/HBoxContainer/HabDebug
@onready var debug_food = $MarginContainer/HBoxContainer/MarginContainer2/HBoxContainer/FoodDebug
@onready var debug_water = $MarginContainer/HBoxContainer/MarginContainer3/HBoxContainer/WaterDebug
@onready var debug_air = $MarginContainer/HBoxContainer/MarginContainer4/HBoxContainer/AirDebug


func _ready():
	ResourceManager.population_changed.connect(_update_pop_ui)
	ResourceManager.workers_changed.connect(_update_worker_ui)
#	ResourceManager.housing_changed.connect(_update_housing_ui)
#	ResourceManager.food_changed.connect(_update_food_ui)
#	ResourceManager.water_changed.connect(_update_water_ui)
#	ResourceManager.air_changed.connect(_update_air_ui)
	#
	ResourceManager.housing_modifier_changed.connect(_update_debug_hab)
	ResourceManager.food_modifier_changed.connect(_update_debug_food)
	ResourceManager.water_modifier_changed.connect(_update_debug_water)
	ResourceManager.air_modifier_changed.connect(_update_debug_air)


func animate_bar(bar, value) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(
		bar, "value", value, 0.4
	).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)


func _update_pop_ui(value):
	population_counter.text = str(value)


func _update_worker_ui(value):
	worker_counter.text = str(value)


#func _update_housing_ui(value):
#	animate_bar(housing_bar, value)
#
#
#func _update_food_ui(value):
#	animate_bar(food_bar, value)
#
#
#func _update_water_ui(value):
#	animate_bar(water_bar, value)
#
#
#func _update_air_ui(value):
#	animate_bar(air_bar, value)


#func _update_debug_pop(production, consumption, total):
#	pass
##	debug_pop.text = "Pop +{0}|-{1}|{2}".format([str(production), str(consumption), str(total)])


func _update_debug_hab(total, modifier):
	var modifier_str = str(round(modifier))
	var modifier_prefix = ""
	if modifier > 0:
		modifier_prefix = "+" 
	debug_hab.text = "{0} ({1}{2})".format([str(round(total)), modifier_prefix, modifier_str])


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

