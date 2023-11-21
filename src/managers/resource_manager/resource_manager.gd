extends Node

signal population_changed(value)
signal workers_changed(value)
signal housing_changed(total, available)
signal food_changed(value)
signal water_changed(value)
signal air_changed(value)
signal metal_changed(value)
#
signal food_modifier_changed(total, modifier)
signal water_modifier_changed(total, modifier)
signal air_modifier_changed(total, modifier)
signal metal_modifier_changed(total, modifier)
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

var food_alert_shown = false
var water_alert_shown = false
var air_alert_shown = false

const FAROQ_KHAN_BONUS = 1.5
const GOVERNOR_BONUS = 2

# How many ticks/days/turns each endgame flag can go on for before you lose
var starving_time: int = 9
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
var suffocating_time: int = 3
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
		if value == is_starving:
			return
		is_starving = value
		emit_signal("starving", starving_time)
var is_thirsty = false:
	set(value):
		if value == is_thirsty:
			return
		is_thirsty = value
		emit_signal("dehydrated", thirsty_time)
var is_suffocating = false:
	set(value):
		if value == is_suffocating:
			return
		is_suffocating = value
		emit_signal("suffocating", suffocating_time)


enum RESOURCE_TYPE {
	POPULATION,
	HOUSING,
	FOOD,
	WATER,
	AIR,
	METAL
}

var current_officers = [EnumAutoload.Officer.PRESSLEY, EnumAutoload.Officer.TORGON]

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
var metal_amount: int:
	set(value):
		metal_amount = value
		emit_signal("metal_changed", metal_amount)

var current_food_modifier: int = 0
var current_air_modifier: int = 0
var current_water_modifier: int = 0
var current_metal_modifier: int = 0

# How many resources-per-tick does one person cost?
var pop_housing_cost: int = 1
var pop_food_cost: int = 2
var pop_water_cost: int = 3
var pop_air_cost: int = 1

func _ready() -> void:
	TickManager.tick.connect(_on_tick)

	reset_state()

	pop_housing_cost = 1
	pop_food_cost = 2
	pop_water_cost = 2
	pop_air_cost = 1


# TODO: Can be optimized, only run on build/tick event, not every frame
func _physics_process(delta):
	for idx in range(0, 6):
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
			RESOURCE_TYPE.METAL:
				emit_signal("metal_modifier_changed", metal_amount, current_metal_modifier)

func calculate_resource_modifier(resource_type, population) -> void:
	var production = 0
	var consumption = 0
	var modifier = 0
	match resource_type:
		RESOURCE_TYPE.HOUSING:
			# Housing is an outlier, we don't update per turn we just keep track
			# of used and avaialble housing
			for building in BuildingManager.buildings:
				production += building.data.housing_prod
			if EnumAutoload.Officer.GOVERNOR in current_officers and production > 0:
				production = (int)(GOVERNOR_BONUS * production)
			consumption = population_amount
			#
			housing_amount = production
			available_housing = production - consumption
		RESOURCE_TYPE.FOOD:
			for building in BuildingManager.buildings:
				production += building.data.food_prod
			if EnumAutoload.Officer.FAROQ_KHAN in current_officers and production > 0:
				production = (int)(FAROQ_KHAN_BONUS * production)
			consumption = population * pop_food_cost
			current_food_modifier = production - consumption
		RESOURCE_TYPE.WATER:
			for building in BuildingManager.buildings:
				production += building.data.water_prod
			consumption = population * pop_water_cost
			current_water_modifier = production - consumption
		RESOURCE_TYPE.AIR:
			for building in BuildingManager.buildings:
				production += building.data.air_prod
			consumption = population * pop_air_cost
			current_air_modifier = production - consumption
		RESOURCE_TYPE.METAL:
			for building in BuildingManager.buildings:
				production += building.data.metal_prod
			current_metal_modifier = production


func update_resource_tick() -> void:
	# When we receive a tick signal from the GameTickManager 
	# we update our resource levels.
	food_amount = clamp(food_amount + current_food_modifier, 0, 999)
	water_amount = clamp(water_amount + current_water_modifier, 0, 999)
	air_amount = clamp(air_amount + current_air_modifier, 0, 999)
	metal_amount = clamp(metal_amount + current_metal_modifier, 0, 999)
	
	# TODO - change resource UI colours over low threshold
	
	# Tick down loss counters
	if is_starving and current_food_modifier < 0 :
		starving_time_left -= 1
		print("Starving: " + str(starving_time_left) + " ticks left")
	if is_thirsty and current_water_modifier < 0:
		thirsty_time_left -= 1
		print("Thirsty: " + str(thirsty_time_left) + " ticks left")
	if is_suffocating and current_air_modifier < 0:
		suffocating_time_left -= 1
		print("Suffocating: " + str(suffocating_time_left) + " ticks left")
	
	# Reset loss counters if they've changed
	is_starving = food_amount == 0 and current_food_modifier < 0
	is_thirsty = water_amount == 0 and current_water_modifier < 0
	is_suffocating = air_amount == 0 and current_air_modifier < 0


func can_add_population(value) -> bool:
	# We can only add population if we have enough housing for it
	if value <= available_housing:
		return true
	else:
		return false

func add_building(building: Building):
	if building not in BuildingManager.buildings:
		BuildingManager.buildings.append(building)


func remove_building(building: Building):
	if building in BuildingManager.buildings:
		BuildingManager.buildings.erase(building)


func assign_workers(building: Building):
	var workers_needed = building.data.people_cost
	var metal_needed = building.data.metal_cost
	if workers_needed > worker_amount or metal_needed > metal_amount:
		return
	
	worker_amount -= workers_needed
	metal_amount -= metal_needed


func retrieve_workers(building: Building):
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
		"metal":
			metal_amount += amount
		"population":
			if amount > 0:
				var empty_spot = housing_amount - population_amount
				if amount <= empty_spot:
					population_amount += amount
			else:
				population_amount += amount
		"population_forced":
			population_amount += amount

func change_specialist_from_event(operation: String, specialist_name: String):
	var specialist = null
	match specialist_name:
		"faroq_khan":
			specialist = EnumAutoload.Officer.FAROQ_KHAN
		"governor_jerrerod":
			specialist = EnumAutoload.Officer.GOVERNOR
	if specialist != null:
		if operation == "add":
			add_specialist(specialist)
		else:
			remove_specialist(specialist)
			

func wake_up_citizen(water_cost) -> String:
	if water_amount < 15:
		return "fail_water"
	if available_housing <= 0:
		return "fail_housing"
	population_amount += 1
	water_amount -= water_cost
	return "success"


func add_specialist(specialist: EnumAutoload.Officer):
	if specialist not in current_officers:
		current_officers.append(specialist)
	print("Add spaecialist")		
	update_specialist_bonus()

func remove_specialist(specialist: EnumAutoload.Officer):
	if specialist in current_officers:
		current_officers.erase(specialist)
	update_specialist_bonus()
	print("Remove spaecialist")		

func update_specialist_bonus():
	return

func reset_state():
	# TODO - load initial values from file for difficulty settings
	population_amount = 3
	housing_amount = 0
	food_amount = 150
	water_amount = 250
	air_amount = 200
	metal_amount = 10

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
	current_officers = [EnumAutoload.Officer.PRESSLEY, EnumAutoload.Officer.TORGON]
	update_specialist_bonus()