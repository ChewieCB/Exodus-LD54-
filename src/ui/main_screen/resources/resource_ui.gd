extends Control

@onready var population_counter = $MarginContainer/HBoxContainer/MarginContainer5/Label
@onready var housing_bar = $MarginContainer/HBoxContainer/MarginContainer/HousingBar
@onready var food_bar = $MarginContainer/HBoxContainer/MarginContainer2/FoodBar
@onready var water_bar = $MarginContainer/HBoxContainer/MarginContainer3/WaterBar
@onready var air_bar = $MarginContainer/HBoxContainer/MarginContainer4/AirBar


func _ready():
	ResourceManager.population_changed.connect(_update_pop_ui)
	ResourceManager.housing_changed.connect(_update_housing_ui)
	ResourceManager.food_changed.connect(_update_food_ui)
	ResourceManager.water_changed.connect(_update_water_ui)
	ResourceManager.air_changed.connect(_update_air_ui)


func animate_bar(bar, value) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(
		bar, "value", value, 0.4
	).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
#	tween.tween_callback(tween.queue_free)


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


