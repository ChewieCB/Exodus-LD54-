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


func _update_pop_ui(value):
	population_counter.text = str(value)


func _update_housing_ui(value):
	housing_bar.value = value


func _update_food_ui(value):
	food_bar.value = value


func _update_water_ui(value):
	water_bar.value = value


func _update_air_ui(value):
	air_bar.value = value


