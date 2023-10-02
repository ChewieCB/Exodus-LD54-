extends Node

signal population_changed(value)
signal workers_changed(value)
signal housing_changed(total, available)
signal food_changed(value)
signal water_changed(value)
signal air_changed(value)
#
signal food_modifier_changed(total, modifier)
signal water_modifier_changed(total, modifier)
signal air_modifier_changed(total, modifier)
#
signal starving(ticks_left)
signal dehydrated(ticks_left)
signal suffocating(ticks_left)
signal stopped_starving
signal stopped_thirsty
signal stopped_suffocating
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
			emit_signal("stopped_starving")
		is_starving = value
		emit_signal("starving", starving_time_left)
		if not is_starving:
			starving_time_left = starving_time
var is_thirsty = false:
	set(value):
		if value == false and is_thirsty == true:
			emit_signal("stopped_thirsty")
		is_thirsty = value
		emit_signal("dehydrated", thirsty_time_left)
		if not is_thirsty:
			thirsty_time_left = thirsty_time
var is_suffocating = false:
	set(value):
		if value == false and is_suffocating == true:
			emit_signal("stopped_suffocating")
		is_suffocating = value
		emit_signal("suffocating", suffocating_time_left)
		if not is_suffocating:
			suffocating_time_left = suffocating_time
# How many ticks/days/turns each endgame flag can go on for before you lose
var starving_time: int = 10
var starving_time_left = starving_time:
	set(value):
		starving_time_left = value
		emit_signal("starving", starving_time_left)
		if starving_time_left == 0:
			emit_signal("game_over", RESOURCE_TYPE.FOOD)
var thirsty_time: int = 6
var thirsty_time_left = thirsty_time:
	set(value):
		thirsty_time_left = value
		emit_signal("dehydrated", thirsty_time_left)
		if thirsty_time_left == 0:
			emit_signal("game_over", RESOURCE_TYPE.WATER)
var suffocating_time: int = 3
var suffocating_time_left = suffocating_time:
	set(value):
		suffocating_time_left = value
		emit_signal("suffocating", suffocating_time_left)
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
# Pop/Worker
var population_amount: int:
	set(value):
		var diff = value - population_amount
		population_amount = value
		emit_signal("population_changed", population_amount)
		# We want to add new population to the worker pool, but only new pop
		# to avoid resetting already assigned workers
		if diff > 0:
			worker_amount = worker_amount + diff
var worker_amount: int:
	set(value):
		worker_amount = value
		emit_signal("workers_changed", worker_amount)
# Other resources
#
#
# HOUSING
var housing_amount: int:
	set(value):
		housing_amount = value
		emit_signal("housing_changed", housing_amount, available_housing)
var available_housing: int = housing_amount - population_amount
#
#
#
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
	TickManager.tick.connect(_on_tick)
	# TODO - load initial values from file for difficulty settings
	population_amount = 3
	#
	pop_housing_cost = 1
	pop_food_cost = 2
	pop_water_cost = 3
	pop_air_cost = 1
	# Thresholds to alert the player to low resource
	housing_low_threshold = 0
	food_low_threshold = 10
	water_low_threshold = 10
	air_low_threshold = 10


func _physics_process(delta):
	for idx in range(0, 5):
		calculate_resource_modifier(idx, population_amount)
		match idx:
			RESOURCE_TYPE.POPULATION:
				pass
			RESOURCE_TYPE.HOUSING:
				pass
			RESOURCE_TYPE.FOOD:
				emit_signal("food_modifier_changed", food_amount, current_food_modifier)
			RESOURCE_TYPE.WATER:
				emit_signal("water_modifier_changed", water_amount, current_water_modifier)
			RESOURCE_TYPE.AIR:
				emit_signal("air_modifier_changed", air_amount, current_air_modifier)
	
	# TODO - add UI update here but NOT total recalculation
	if Input.is_action_just_pressed("DEBUG_add_population"):
		if can_add_population(1):
			population_amount += 1
		else:
			print("Can't add {0} population, not enough housing!".format(["1"]))


func calculate_resource_modifier(resource_type, population) -> void:
	var production = 0
	var consumption = 0
	var modifier = 0
	match resource_type:
		RESOURCE_TYPE.HOUSING:
			# Housing is an outlier, we don't update per turn we just keep track
			# of used and avaialble housing
			for building in buildings:
				production += building.data.housing_prod
			consumption = population_amount
			#
			housing_amount = production
			available_housing = production - consumption
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


func can_add_population(value) -> bool:
	# We can only add population if we have enough housing for it
	if population_amount + value < housing_amount:
		return true
	else:
		return false

func add_building(building):
	if building not in buildings:
		buildings.append(building)


func remove_building(building):
	if building in buildings:
		buildings.erase(building)


func assign_workers(building):
	# TODO - we can also handle material cost here
	var workers_needed = building.data.people_cost
	# Check that there are {number_of_workers} free in the current worker pool
	if workers_needed > worker_amount:
		return 
	# Update the worker pool
	worker_amount -= workers_needed


func retrieve_workers(building):
	# Refund X workers assigned to a completed building from the building's cost data
	worker_amount += building.data.people_cost


func _on_tick():
	update_resource_tick()
