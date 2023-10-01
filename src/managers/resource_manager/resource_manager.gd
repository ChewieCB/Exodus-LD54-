extends Node

signal population_changed(value)
signal housing_changed(value)
signal food_changed(value)
signal water_changed(value)
signal air_changed(value)
#
signal population_modifier_changed(total, modifier)
signal housing_modifier_changed(total, modifier)
signal food_modifier_changed(total, modifier)
signal water_modifier_changed(total, modifier)
signal air_modifier_changed(total, modifier)

enum RESOURCE_TYPE {
	POPULATION,
	HOUSING,
	FOOD,
	WATER,
	AIR
}

# Resources to be managed
var population_amount: int:
	set(value):
		population_amount = value
		emit_signal("population_changed", population_amount)
var housing_amount: int:
	set(value):
		housing_amount = value
		emit_signal("housing_changed", housing_amount)
var food_amount: int:
	set(value):
		food_amount = value
		emit_signal("food_changed", food_amount)
var water_amount: int:
	set(value):
		water_amount = value
		emit_signal("water_changed", water_amount)
var air_amount: int:
	set(value):
		air_amount = value
		emit_signal("air_changed", air_amount)

var current_housing_modifier: int = 0
var current_food_modifier: int = 0
var current_air_modifier: int = 0
var current_water_modifier: int = 0


# How many resources-per-tick does one person cost?
var pop_housing_cost: int
var pop_food_cost: int
var pop_water_cost: int
var pop_air_cost: int

# 
var buildings = []


func _ready() -> void:
	# TODO - load initial values from file for difficulty settings
	population_amount = 5
	housing_amount = 5
	food_amount = 200
	water_amount = 300
	air_amount = 150
	#
	pop_housing_cost = 1
	pop_food_cost = 2
	pop_water_cost = 3
	pop_air_cost = 1


func _physics_process(delta):
	for idx in range(4):
		calculate_resource_modifier(idx, population_amount)
		match idx:
			RESOURCE_TYPE.HOUSING:
				emit_signal("housing_modifier_changed", housing_amount, current_housing_modifier)
			RESOURCE_TYPE.FOOD:
				emit_signal("food_modifier_changed", food_amount, current_food_modifier)
			RESOURCE_TYPE.WATER:
				emit_signal("water_modifier_changed", water_amount, current_water_modifier)
			RESOURCE_TYPE.AIR:
				emit_signal("air_modifier_changed", air_amount, current_air_modifier)
	
	# TODO - add UI update here but NOT total recalculation
	if Input.is_action_just_pressed("DEBUG_add_population"):
		population_amount += 1


func calculate_resource_modifier(resource_type, population) -> void:
	var production = 0
	var consumption = 0
	for building in buildings:
		match resource_type:
			RESOURCE_TYPE.HOUSING:
				production += building.data.housing_prod
				consumption += population * pop_housing_cost
			RESOURCE_TYPE.FOOD:
				production += building.data.food_prod
				consumption += population * pop_food_cost
			RESOURCE_TYPE.WATER:
				production += building.data.water_prod
				consumption += population * pop_water_cost
			RESOURCE_TYPE.AIR:
				production += building.data.air_prod
				consumption += population * pop_air_cost
	
	var modifier = production - consumption
	
	match resource_type:
			RESOURCE_TYPE.HOUSING:
				current_housing_modifier = modifier
			RESOURCE_TYPE.FOOD:
				current_food_modifier = modifier
			RESOURCE_TYPE.WATER:
				current_water_modifier = modifier
			RESOURCE_TYPE.AIR:
				current_air_modifier = modifier
	


func update_resource_tick() -> void:
	# When we receive a tick signal from the GameTickManager 
	# we update our resource levels.
	housing_amount += current_housing_modifier
	food_amount += current_food_modifier
	water_amount += current_water_modifier
	air_amount += current_air_modifier


func add_building(building):
	buildings.append(building)


func remove_building(building):
	buildings.erase(building)


func _on_timer_timeout():
	update_resource_tick()
