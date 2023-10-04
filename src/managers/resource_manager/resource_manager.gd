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

signal ui_hover_show(text)
signal ui_hover_hide

signal construction_cancelled_lack_of_workers(building_name)

var housing_alert_shown = false
var food_alert_shown = false
var water_alert_shown = false
var air_alert_shown = false

# How many ticks/days/turns each endgame flag can go on for before you lose
var starving_time: int = 10
var starving_time_left = starving_time:
	set(value):
		starving_time_left = value
		if is_starving:
			emit_signal("starving", starving_time_left)
			if starving_time_left == 0:
				emit_signal("game_over", RESOURCE_TYPE.FOOD)
var thirsty_time: int = 6
var thirsty_time_left = thirsty_time:
	set(value):
		thirsty_time_left = value
		if is_thirsty:
			emit_signal("dehydrated", thirsty_time_left)
			if thirsty_time_left == 0:
				emit_signal("game_over", RESOURCE_TYPE.WATER)
var suffocating_time: int = 6
var suffocating_time_left = suffocating_time:
	set(value):
		suffocating_time_left = value
		if is_suffocating:
			emit_signal("suffocating", suffocating_time_left)
			if suffocating_time_left == 0:
				emit_signal("game_over", RESOURCE_TYPE.AIR)

# Endgame flags, if any of these last too long its game over
var is_starving = false:
	set(value):
		if value == false and is_starving == true:
			emit_signal("stopped_starving", starving_time)
		if value == true and is_starving == false:
			emit_signal("starving", starving_time)
		is_starving = value
var is_thirsty = false:
	set(value):
		if value == false and is_thirsty == true:
			emit_signal("stopped_thirsty", thirsty_time)
		if value == true and is_thirsty == false:
			emit_signal("dehydrated", thirsty_time)
		is_thirsty = value
var is_suffocating = false:
	set(value):
		if value == false and is_suffocating == true:
			emit_signal("stopped_suffocating", suffocating_time)
		if value == true and is_suffocating == false:
			emit_signal("suffocating", suffocating_time)
		is_suffocating = value


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
		# FIXME - This is probably gonna cause a negative worker number if
		# we lose pop mid-construction
		worker_amount += diff
		available_housing += diff

var worker_amount: int:
	set(value):
		# If the value will take us less than 0, we've got workers assigned
		# to buildings - so cancel the most recent buildings under construction,
		# and refund the workers until we're at 0 or above.
		if value < 0:
			var worker_refund = 0
			while value + worker_refund < 0:
				var current_refund = 0
				var most_recent_building = BuildingManager.construction_queue.pop_front()
				print(most_recent_building)
				current_refund = most_recent_building.data.people_cost
				worker_refund += current_refund
				# 
				if most_recent_building.is_constructing:
					emit_signal("construction_cancelled_lack_of_workers", most_recent_building.data.name)
					most_recent_building.cancel_building(true)
				elif most_recent_building.is_deconstructing:
					emit_signal("construction_cancelled_lack_of_workers", most_recent_building.data.name)
					most_recent_building.cancel_building_remove(true)
			# Assign the new value
			value += worker_refund
			
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

	reset_state()

	pop_housing_cost = 1
	pop_food_cost = 2
	pop_water_cost = 2
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
			consumption = population * pop_water_cost
			current_water_modifier = production - consumption
		RESOURCE_TYPE.AIR:
			for building in buildings:
				production += building.data.air_prod
			consumption = population * pop_air_cost
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
	if value <= available_housing:
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


func check_if_all_crew_died():
	if population_amount <= 0:
		population_amount = 0
		emit_signal("game_over", RESOURCE_TYPE.POPULATION)


func change_resource_from_event(resource: String, amount_str: String):
	var amount = int(amount_str)
	match resource:
		"food":
			food_amount += amount
		"water":
			water_amount += amount
		"air":
			air_amount += amount
		"population":
			if amount > 0:
				var empty_spot = housing_amount - population_amount
				if amount <= empty_spot:
					population_amount += amount
			else:
				population_amount += amount


func reset_state():
	# TODO - load initial values from file for difficulty settings
	population_amount = 3

	housing_alert_shown = false
	food_alert_shown = false
	water_alert_shown = false
	air_alert_shown = false
	is_starving = false
	is_thirsty = false
	is_suffocating = false
	starving_time_left = starving_time
	thirsty_time_left = thirsty_time
	suffocating_time_left = suffocating_time
	current_food_modifier = 0
	current_air_modifier = 0
	current_water_modifier = 0
	buildings = []