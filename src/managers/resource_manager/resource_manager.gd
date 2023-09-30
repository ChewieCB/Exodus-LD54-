extends Node

signal population_changed(value)
signal housing_changed(value)
signal food_changed(value)
signal water_changed(value)
signal air_changed(value)

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
# Decay rates
var food_decay_rate: float
var water_decay_rate: float
var air_decay_rate: float

# 
var hab_buildings = []
var food_buildings = []
var water_buildings = []
var air_buildings = []


func _ready() -> void:
	# TODO - load initial values from file for difficulty settings
	population_amount = 12
	housing_amount = 100
	food_amount = 100
	water_amount = 100
	air_amount = 100
	
	food_decay_rate = 0.15
	water_decay_rate = 0.2
	air_decay_rate = 0.1


func _physics_process(delta):
	if Input.is_action_just_pressed("DEBUG_add_population"):
		population_amount += 1


func update_resource_tick() -> void:
	# When we receive a tick signal from the GameTickManager 
	# we update our resource levels.
	housing_amount = clamp(housing_amount - population_amount, 0, INF)
	food_amount = calculate_resource_amount(food_amount, food_decay_rate)
	water_amount = calculate_resource_amount(water_amount, water_decay_rate)
	air_amount = calculate_resource_amount(air_amount, air_decay_rate)


func calculate_resource_amount(resource, decay_rate) -> float:
	return resource - (decay_rate * population_amount)


func add_building(building):
	# TODO - implement with building resource types
	pass
#	match building.type:
#		HabBuilding:
#			hab_buildings.append(building)
#		FoodBuilding:
#			food_buildings.append(building)
#		WaterBuilding:
#			water_buildings.append(building)
#		AirBuilding:
#			air_buildings.append(building)


func remove_building(building):
	# TODO - implement with building resource types
	pass
#	match building.type:
#		HabBuilding:
#			hab_buildings.erase(building)
#		FoodBuilding:
#			food_buildings.erase(building)
#		WaterBuilding:
#			water_buildings.erase(building)
#		AirBuilding:
#			air_buildings.erase(building)


func _on_timer_timeout():
	# TEMP - replace with more sophisticated tick manager we can pause
	update_resource_tick()
