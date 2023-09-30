extends Control

@onready var population_counter = $MarginContainer2/HBoxContainer/MarginContainer5/Label
@onready var housing_bar = $MarginContainer2/HBoxContainer/MarginContainer/HousingBar
@onready var food_bar = $MarginContainer2/HBoxContainer/MarginContainer2/FoodBar
@onready var water_bar = $MarginContainer2/HBoxContainer/MarginContainer3/WaterBar
@onready var air_bar = $MarginContainer2/HBoxContainer/MarginContainer4/AirBar

@onready var debug_pop = $MarginContainer/HBoxContainer/MarginContainer5/PopLabel
@onready var debug_hab = $MarginContainer/HBoxContainer/MarginContainer/HabLabel
@onready var debug_food = $MarginContainer/HBoxContainer/MarginContainer2/FoodLabel
@onready var debug_water = $MarginContainer/HBoxContainer/MarginContainer3/WaterLabel
@onready var debug_air = $MarginContainer/HBoxContainer/MarginContainer4/AirLabel


func _ready():
	ResourceManager.population_changed.connect(_update_pop_ui)
	ResourceManager.housing_changed.connect(_update_housing_ui)
	ResourceManager.food_changed.connect(_update_food_ui)
	ResourceManager.water_changed.connect(_update_water_ui)
	ResourceManager.air_changed.connect(_update_air_ui)
	#
	ResourceManager.population_diff.connect(_update_debug_pop)
	ResourceManager.housing_diff.connect(_update_debug_hab)
	ResourceManager.food_diff.connect(_update_debug_food)
	ResourceManager.water_diff.connect(_update_debug_water)
	ResourceManager.air_diff.connect(_update_debug_air)


func animate_bar(bar, value) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(
		bar, "value", value, 0.4
	).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)


func _update_pop_ui(value):
	population_counter.text = str(value)


func _update_housing_ui(value):
	animate_bar(housing_bar, value)


func _update_food_ui(value):
	animate_bar(food_bar, value)


func _update_water_ui(value):
	animate_bar(water_bar, value)


func _update_air_ui(value):
	animate_bar(air_bar, value)


func _update_debug_pop(production, consumption, total):
	debug_pop.text = "Pop +{0}|-{1}|{2}".format([str(production), str(consumption), str(total)])


func _update_debug_hab(production, consumption, total):
	debug_hab.text = "Hab +{0}|-{1}|{2}".format([str(production), str(consumption), str(total)])


func _update_debug_food(production, consumption, total):
	debug_food.text = "Food +{0}|-{1}|{2}".format([str(production), str(consumption), str(total)])


func _update_debug_water(production, consumption, total):
	debug_water.text = "Water +{0}|-{1}|{2}".format([str(production), str(consumption), str(total)])


func _update_debug_air(production, consumption, total):
	debug_air.text = "Air +{0}|-{1}|{2}".format([str(production), str(consumption), str(total)])

