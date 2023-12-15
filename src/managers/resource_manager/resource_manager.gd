extends Node

signal population_changed(value)
signal workers_changed(value)
signal housing_changed(total, available)
signal food_changed(value)
signal water_changed(value)
signal air_changed(value)
signal metal_changed(value)
#
signal morale_changed(value)
#
signal food_modifier_changed(total, modifier)
signal water_modifier_changed(total, modifier)
signal air_modifier_changed(total, modifier)
signal metal_modifier_changed(total, modifier)
#
signal starving(ticks_left)
signal dehydrated(ticks_left)
signal suffocating(ticks_left)
signal mutiny(ticks_left)
signal stopped_starving
signal stopped_thirsty
signal stopped_suffocating
signal stopped_mutiny
#
signal resource_low(resource)
signal game_over(resource)

signal ui_hover_show(text)
signal ui_hover_hide

signal construction_cancelled_lack_of_workers(building_name)

signal upgrade_acquired

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
var mutiny_time: int = 3
var mutiny_time_left = mutiny_time:
	set(value):
		mutiny_time_left = value
		if morale_amount == -100:
			emit_signal("mutiny", mutiny_time_left)
			if mutiny_time_left == 0:
				emit_signal("game_over", RESOURCE_TYPE.MORALE)

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
var is_mutiny = false:
	set(value):
		if value == is_mutiny:
			return
		is_mutiny = value
		emit_signal("mutiny", mutiny_time)


enum RESOURCE_TYPE {
	POPULATION,
	HOUSING,
	FOOD,
	WATER,
	AIR,
	METAL,
	MORALE
}

var current_officers = [EnumAutoload.Officer.PRESSLEY, EnumAutoload.Officer.TORGON]
var current_upgrades = []

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
		CrewmateManager.update_current_crewmates(value)
		#
		if diff < 0:
			current_morale_modifier -= crew_loss_morale_impact * abs(diff)
		elif diff > 0:
			current_morale_modifier += crew_gain_morale_impact * abs(diff)
		

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
var available_housing: int = housing_amount - population_amount:
	set(value):
		available_housing = value
		habitability = calculate_habitability_score()
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
var morale_amount: int:
	set(value):
		morale_amount = value
		emit_signal("morale_changed", morale_amount)

var current_food_modifier: int = 0
var current_air_modifier: int = 0
var current_water_modifier: int = 0
var current_metal_modifier: int = 0

# How many resources-per-tick does one person cost?
var pop_housing_cost: int = 1
var pop_food_cost: int = 2
var pop_water_cost: int = 3
var pop_air_cost: int = 1

var habitability: int = 0:
	set(value):
		habitability = clamp(value, -100, 100)
		morale_amount = habitability + current_morale_modifier
# This modifier is accumulated from per-event morale changes
var current_morale_modifier: int = 0:
	set(value):
		current_morale_modifier = value
		morale_amount = habitability + current_morale_modifier
# How much does each resource affect habitability?
var housing_habitability_impact: int = 8
@export var housing_impact_curve: Curve
# Weights for one-off events impacting morale
var crew_loss_morale_impact: int = 20
var crew_gain_morale_impact: int = 10


func _ready() -> void:
	TickManager.tick.connect(_on_tick)

	reset_state()

	pop_housing_cost = 1
	pop_food_cost = 2
	pop_water_cost = 2
	pop_air_cost = 1
	
	current_morale_modifier = 0


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
			if EnumAutoload.Officer.GOVERNOR_JERREROD in current_officers and production > 0:
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


func calculate_habitability_score() -> int:
	var new_habitability: int = 0
	var housing_mod = available_housing * housing_habitability_impact
	var housed_ratio: float = clamp(
		float(available_housing) / float(population_amount),
		0, 3
	)
	var lower_map = remap(housed_ratio, 0.0, 1.0, 0.0, 0.5)
	var higher_map = remap(housed_ratio, 1.0, 10.0, 0.5, 1)
	var sample_map
	if housed_ratio <= 1.0:
		sample_map = lower_map
	else:
		sample_map = higher_map
	new_habitability = housing_mod * housing_impact_curve.sample(sample_map)
	
	return new_habitability


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
	if is_mutiny:
		mutiny_time_left -= 1
		print("Mutiny: " + str(mutiny_time_left) + " ticks left")

	# Reset loss counters if they've changed
	is_starving = food_amount == 0 and current_food_modifier < 0
	is_thirsty = water_amount == 0 and current_water_modifier < 0
	is_suffocating = air_amount == 0 and current_air_modifier < 0
	is_mutiny = morale_amount == -100


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
	worker_amount -= workers_needed


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
			specialist = EnumAutoload.Officer.GOVERNOR_JERREROD
		"dr_dorian":
			specialist = EnumAutoload.Officer.DR_DORIAN
		"mary_watney":
			specialist = EnumAutoload.Officer.MARY_WATNEY
		"sam_carter":
			specialist = EnumAutoload.Officer.SAM_CARTER
	if specialist != null:
		if operation == "add":
			add_specialist(specialist)
		else:
			remove_specialist(specialist)


func add_specialist(specialist: EnumAutoload.Officer):
	if specialist not in current_officers:
		current_officers.append(specialist)
	print("Add specialist")
	update_specialist_bonus()


func remove_specialist(specialist: EnumAutoload.Officer):
	if specialist in current_officers:
		current_officers.erase(specialist)
	update_specialist_bonus()
	print("Remove specialist")


func update_specialist_bonus():
	return


func add_upgrade(upgrade_id: EnumAutoload.UpgradeId):
	current_upgrades.append(upgrade_id)
	emit_signal("upgrade_acquired")


func reset_state():
	# TODO - load initial values from file for difficulty settings
	population_amount = 3
	housing_amount = 0
	food_amount = 150
	water_amount = 250
	air_amount = 200
	metal_amount = 10
	morale_amount = 0

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
	current_upgrades = []
	update_specialist_bonus()
