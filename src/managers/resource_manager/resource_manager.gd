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
#
signal resource_low(resource)
signal game_over(resource)

var housing_alert_shown = false
var food_alert_shown = false
var water_alert_shown = false
var air_alert_shown = false

# Endgame flags, if any of these last too long its game over
var is_starving = false:
	set(value):
		if value == false and is_starving == true:
			print("No longer starving!")
		is_starving = value
		if not is_starving:
			starving_time_left = starving_time
var is_thirsty = false:
	set(value):
		if value == false and is_thirsty == true:
			print("No longer thirsty!")
		is_thirsty = value
		if not is_thirsty:
			thirsty_time_left = thirsty_time
var is_suffocating = false:
	set(value):
		if value == false and is_suffocating == true:
			print("No longer suffocating!")
		is_suffocating = value
		if not is_suffocating:
			suffocating_time_left = suffocating_time
# How many ticks/days/turns each endgame flag can go on for before you lose
var starving_time: int = 10
var starving_time_left = starving_time:
	set(value):
		starving_time_left = value
		if starving_time_left == 0:
			emit_signal("game_over", RESOURCE_TYPE.FOOD)
var thirsty_time: int = 6
var thirsty_time_left = thirsty_time:
	set(value):
		thirsty_time_left = value
		if thirsty_time_left == 0:
			emit_signal("game_over", RESOURCE_TYPE.WATER)
var suffocating_time: int = 3
var suffocating_time_left = suffocating_time:
	set(value):
		suffocating_time_left = value
		if suffocating_time_left == 0:
			emit_signal("game_over", RESOURCE_TYPE.AIR)

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
var pop_housing_cost: int = 1
var pop_food_cost: int = 2
var pop_water_cost: int = 3
var pop_air_cost: int = 1

#
var housing_low_threshold: int = 2
var food_low_threshold: int = 2
var water_low_threshold: int = 3
var air_low_threshold: int = 2

# 
var buildings = []


func _ready() -> void:
	# TODO - load initial values from file for difficulty settings
	population_amount = 3
	# This is derived purely from the buildings we have placed
	housing_amount = 0
	food_amount = 20
	water_amount = 300
	air_amount = 150
	#
	pop_housing_cost = 1
	pop_food_cost = 2
	pop_water_cost = 3
	pop_air_cost = 1
	# Thresholds to alert the player to low resource
	housing_low_threshold = 2
	food_low_threshold = 10
	water_low_threshold = 10
	air_low_threshold = 10


func start_ticks():
	$Timer.start()


func stop_ticks():
	$Timer.stop()


func _physics_process(delta):
	for idx in range(1, 5):
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
	var modifier = 0
	match resource_type:
		RESOURCE_TYPE.HOUSING:
			for building in buildings:
				production += building.data.housing_prod
			consumption = population * pop_housing_cost
			current_housing_modifier = production - consumption
		RESOURCE_TYPE.FOOD:
			for building in buildings:
				production += building.data.food_prod
			consumption = population * pop_food_cost
			current_food_modifier = production - consumption
		RESOURCE_TYPE.WATER:
			for building in buildings:
				production += building.data.water_prod
			consumption += population * pop_water_cost
			current_water_modifier = production - consumption
		RESOURCE_TYPE.AIR:
			for building in buildings:
				production += building.data.air_prod
			consumption += population * pop_air_cost
			current_air_modifier = production - consumption


func update_resource_tick() -> void:
	# When we receive a tick signal from the GameTickManager 
	# we update our resource levels.
	housing_amount = clamp(housing_amount + current_housing_modifier, 0, 999)
	food_amount = clamp(food_amount + current_food_modifier, 0, 999)
	water_amount = clamp(water_amount + current_water_modifier, 0, 999)
	air_amount = clamp(air_amount + current_air_modifier, 0, 999)
	
	# TODO - change resource UI colours over low threshold
	
	# Tick down loss counters
	if is_starving:
		starving_time_left -= 1
		print("Starving: " + str(starving_time_left) + " ticks left")
	if is_thirsty:
		thirsty_time_left -= 1
		print("Thirsty: " + str(thirsty_time_left) + " ticks left")
	if is_suffocating:
		suffocating_time_left -= 1
		print("Suffocating: " + str(suffocating_time_left) + " ticks left")
	
	# Reset loss counters if they've changed
	is_starving = food_amount == 0
	is_thirsty = water_amount == 0
	is_suffocating = air_amount == 0


func add_building(building):
	if building not in buildings:
		buildings.append(building)


func remove_building(building):
	if building in buildings:
		buildings.erase(building)


func _on_timer_timeout():
	update_resource_tick()
