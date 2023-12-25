extends Node

# Resource value signals
signal population_changed(value)
signal workers_changed(value)
signal morale_effect_applied(updated_effects: Array)
signal morale_effect_removed(updated_effects: Array)
#
signal housing_changed(total, available)
signal food_changed(value)
signal water_changed(value)
signal air_changed(value)
signal metal_changed(value)
signal storage_changed(value)
signal food_modifier_changed(total, modifier)
signal water_modifier_changed(total, modifier)
signal air_modifier_changed(total, modifier)
signal metal_modifier_changed(total, modifier)
#
signal morale_changed(value)

# Fail state signals
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
#
signal ui_hover_show(text)
signal ui_hover_hide
signal morale_detail_show
signal morale_detail_hide

signal construction_cancelled_lack_of_workers(building_name)

signal upgrade_acquired
signal research_completed(research_name)

var food_alert_shown = false
var water_alert_shown = false
var air_alert_shown = false

const FAROQ_KHAN_BONUS = 1.5
const GOVERNOR_BONUS = 2
const BASE_STORAGE = 500

# Endgame flags, if any of these last too long its game over
# FOOD
var is_starving = false: set = set_is_starving
var starving_time: int = 9 # How many ticks/days/turns each endgame flag can go on for before you lose
var starving_time_left = starving_time: set = set_starving_time_left
# WATER
var is_thirsty = false: set = set_is_thirsty
var thirsty_time: int = 6
var thirsty_time_left = thirsty_time: set = set_thirsty_time_left
# AIR
var is_suffocating = false: set = set_is_suffocating
var suffocating_time: int = 3
var suffocating_time_left = suffocating_time: set = set_suffocating_time_left
# MORALE
var is_mutiny = false: set = set_is_mutiny
var mutiny_time: int = 3
var mutiny_time_left = mutiny_time: set = set_mutiny_time_left

var current_officers = [EnumAutoload.Officer.PRESSLEY, EnumAutoload.Officer.TORGON]
var current_upgrades = []

# Resources to be managed
# Pop/Worker
var population_amount: int: 
	get: return get_population_amount()
	set(value): set_population_amount(value)
# Use a private var here to allow for optional args in setter
var _population_amount: int
var worker_amount: int: set = set_worker_amount
# How many resources-per-tick does one person cost?
var pop_housing_cost: int = 1
var pop_food_cost: int = 2
var pop_water_cost: int = 3
var pop_air_cost: int = 1
# Other resources
# HOUSING
var housing_amount: int: set = set_housing_amount
var available_housing: int = housing_amount - population_amount: set = set_available_housing
# FOOD
var food_amount: int: set = set_food_amount
var current_food_modifier: int = 0
# WATER
var water_amount: int: set = set_water_amount
var current_water_modifier: int = 0
# AIR
var air_amount: int: set = set_air_amount
var current_air_modifier: int = 0
# METAL
var metal_amount: int: set = set_metal_amount
var current_metal_modifier: int = 0
# STORAGE
var storage_resource_amount: ResourceData:
	set(value):
		storage_resource_amount = value
		emit_signal("storage_changed", storage_resource_amount)
# MORALE
var morale_amount: int: set = set_morale_amount
var habitability: int = 0: set = set_habitability
var current_morale_modifier: int = 0: set = set_current_morale_modifier # This modifier is accumulated from per-event morale changes
@export var housing_impact_weight_curve: Curve
var housing_habitability_impact: int = 8
# 
var morale_effect_queue: Array[MoraleEffect] = []
var crew_jettison_morale_impact: int = 35 # This replaces the crew_loss value
var crew_loss_morale_impact: int = 20
var crew_gain_morale_impact: int = 3


func _ready() -> void:
	TickManager.tick.connect(_on_tick)
	CrewmateManager.crewmate_jettisoned.connect(jettison_crewmate)
	
	reset_state()
	
	pop_housing_cost = 1
	pop_food_cost = 2
	pop_water_cost = 2
	pop_air_cost = 1
	
	current_morale_modifier = 0
	update_resource_modifiers()
	emit_signal("morale_changed", morale_amount)


func _on_tick():
	update_resource_modifiers()
	update_resources_with_modifier()


func update_resource_modifiers():
	for idx in range(1, 9):
		calculate_resource_modifier(idx, population_amount)
		match idx:
			EnumAutoload.ResourceType.POPULATION:
				pass
			EnumAutoload.ResourceType.HOUSING:
				emit_signal("housing_changed", housing_amount, available_housing)
			EnumAutoload.ResourceType.FOOD:
				emit_signal("food_modifier_changed", food_amount, current_food_modifier)
			EnumAutoload.ResourceType.WATER:
				emit_signal("water_modifier_changed", water_amount, current_water_modifier)
			EnumAutoload.ResourceType.AIR:
				emit_signal("air_modifier_changed", air_amount, current_air_modifier)
			EnumAutoload.ResourceType.METAL:
				emit_signal("metal_modifier_changed", metal_amount, current_metal_modifier)
			EnumAutoload.ResourceType.MORALE:
				emit_signal("morale_changed", morale_amount)


func calculate_resource_modifier(resource_type, population) -> void:
	var production = 0
	var consumption = 0
	var modifier = 0
	match resource_type:
		EnumAutoload.ResourceType.STORAGE:
			storage_resource_amount.food = BASE_STORAGE 
			storage_resource_amount.air = BASE_STORAGE 
			storage_resource_amount.water = BASE_STORAGE
			storage_resource_amount.metal = BASE_STORAGE 
			for building in BuildingManager.buildings:
				if building is WarehouseBuilding:
					var warehouse = building as WarehouseBuilding
					var resource_capacity = warehouse.get_resource_storage_capacity()
					var mul = ResourceManager.get_storage_with_upgrade_multiplier()
					storage_resource_amount.food += resource_capacity.food * mul
					storage_resource_amount.air += resource_capacity.air * mul
					storage_resource_amount.water += resource_capacity.water * mul
					storage_resource_amount.metal += resource_capacity.metal * mul
		EnumAutoload.ResourceType.HOUSING:
			# Housing is an outlier, we don't update per turn we just keep track
			# of used and avaialble housing
			for building in BuildingManager.buildings:
				production += building.data.housing_prod
			# if EnumAutoload.Officer.GOVERNOR_JERREROD in current_officers and production > 0:
			# 	production = (int)(GOVERNOR_BONUS * production)
			consumption = population_amount
			#
			housing_amount = production
			available_housing = production - consumption
		EnumAutoload.ResourceType.MORALE:
			for effect in morale_effect_queue:
				if effect != null:
					modifier += effect.morale_modifier_value
			current_morale_modifier = modifier
		EnumAutoload.ResourceType.FOOD:
			for building in BuildingManager.buildings:
				production += building.get_produced_resource().food
			# if EnumAutoload.Officer.FAROQ_KHAN in current_officers and production > 0:
			# 	production = (int)(FAROQ_KHAN_BONUS * production)
			consumption = population * pop_food_cost
			current_food_modifier = production - consumption
		EnumAutoload.ResourceType.WATER:
			for building in BuildingManager.buildings:
				production += building.get_produced_resource().water
			consumption = population * pop_water_cost
			current_water_modifier = production - consumption
		EnumAutoload.ResourceType.AIR:
			for building in BuildingManager.buildings:
				production += building.get_produced_resource().air
			consumption = population * pop_air_cost
			current_air_modifier = production - consumption
		EnumAutoload.ResourceType.METAL:
			for building in BuildingManager.buildings:
				production += building.get_produced_resource().metal
			current_metal_modifier = production


func calculate_habitability_score() -> int:
	return clamp(50 + available_housing * housing_habitability_impact, 0, 100)


func update_resources_with_modifier() -> void:
	# When we receive a tick signal from the GameTickManager
	# we update our resource levels.
	food_amount = clamp(food_amount + current_food_modifier, 0, storage_resource_amount.food)
	water_amount = clamp(water_amount + current_water_modifier, 0, storage_resource_amount.water)
	air_amount = clamp(air_amount + current_air_modifier, 0, storage_resource_amount.air)
	metal_amount = clamp(metal_amount + current_metal_modifier, 0, storage_resource_amount.metal)
	morale_amount = clamp(habitability + current_morale_modifier, -100, 100)

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
	update_resource_modifiers()


func assign_workers(building: Building):
	var workers_needed = building.data.people_cost
	worker_amount -= workers_needed


func retrieve_workers(building: Building):
	# Refund X workers assigned to a completed building from the building's cost data
	worker_amount += building.data.people_cost


func check_if_all_crew_died():
	if population_amount <= 0:
		population_amount = 0
		emit_signal("game_over", EnumAutoload.ResourceType.POPULATION)


func change_resource_from_event(resource: String, amount_str: String, custom_effect_msg: String=""):
	var amount = int(amount_str)
	match resource:
		"food":
			food_amount = clamp(food_amount + amount, 0, storage_resource_amount.food)
		"water":
			water_amount = clamp(water_amount + amount, 0, storage_resource_amount.water)
		"air":
			air_amount = clamp(air_amount + amount, 0, storage_resource_amount.air)
		"metal":
			metal_amount = clamp(metal_amount + amount, 0, storage_resource_amount.metal)
		"population":
			if custom_effect_msg:
				set_population_amount(population_amount + amount, false, custom_effect_msg)
			else:
				population_amount += amount
	update_resource_modifiers()


func add_morale_effect_from_event(
		amount_str: String, detail_text: String, 
		effect_length_str: String = "", is_temporary: String = "true"
	):
	var amount = int(amount_str)
	var _is_temporary = is_temporary == "true"
	if _is_temporary:
		var effect_length = int(effect_length_str)
		add_morale_effect(detail_text, amount, effect_length)
	else:
		add_morale_effect(detail_text, amount, -1, MoraleEffect.TYPES.EnvironmentalMoraleEffect)


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


func jettison_crewmate(crewmate):
	add_morale_effect(
		"Jettisoned %s" % [crewmate.crewmate_name], -crew_jettison_morale_impact, 25
	)


func add_upgrade(upgrade_id: EnumAutoload.UpgradeId, upgrade_name: String):
	current_upgrades.append(upgrade_id)
	emit_signal("upgrade_acquired")
	emit_signal("research_completed", upgrade_name)


func check_if_enough_resource(cost: ResourceData) -> bool:
	# return true
	if food_amount < cost.food:
		return false
	if water_amount < cost.water:
		return false
	if air_amount < cost.air:
		return false
	if metal_amount < cost.metal:
		return false
	return true


func change_resource(resource_data: ResourceData, add: bool = true, multiplier: float = 1) -> void:
	var operation_multiplier = 1
	if not add:
		operation_multiplier = -1
	food_amount += ceil(resource_data.food * operation_multiplier * multiplier)
	water_amount += ceil(resource_data.water * operation_multiplier * multiplier)
	air_amount += ceil(resource_data.air * operation_multiplier * multiplier)
	metal_amount += ceil(resource_data.metal * operation_multiplier * multiplier)
	update_resource_modifiers()

func get_build_time_with_upgrade_multiplier() -> float:
	var reduction_perc = 0
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_CREW_CHIEF in current_upgrades:
		reduction_perc += 0.1
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_DEEP_SPACE in current_upgrades:
		reduction_perc += 0.15
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_DRONE in current_upgrades:
		reduction_perc += 0.25
	return clampf(1 - reduction_perc, 0, 1)

func calculate_build_time_with_upgrade(base_time: int) -> int:
	var multiplier = get_build_time_with_upgrade_multiplier()
	return ceil(base_time * multiplier)


func get_build_cost_with_upgrade_multiplier() -> float:
	var reduction_perc = 0
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_IMPROVE_SCHEMATICS in current_upgrades:
		reduction_perc += 0.1
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_AI_ENHANCED_SCHEMATICS in current_upgrades:
		reduction_perc += 0.15
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_AI_GENERATED_SCHEMATICS in current_upgrades:
		reduction_perc += 0.25
	return clampf(1 - reduction_perc, 0, 1)

func calculate_build_cost_with_upgrade(base_cost: int) -> int:
	var multiplier = get_build_cost_with_upgrade_multiplier()
	return ceil(base_cost * multiplier)


func get_storage_with_upgrade_multiplier() -> float:
	var bonus_perc = 0
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_ADV_SORTERS in current_upgrades:
		bonus_perc += 0.25
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_AUTOMATED_WAREHOUSES in current_upgrades:
		bonus_perc += 0.50
	return (1 + bonus_perc)


func calculate_storage_with_upgrade(base_storage: int) -> int:
	var multiplier = get_storage_with_upgrade_multiplier()
	return ceil(base_storage * multiplier)


func reset_state():
	# TODO - load initial values from file for difficulty settings
	# Update the pop without changing morale
	storage_resource_amount = ResourceData.new(BASE_STORAGE, BASE_STORAGE, BASE_STORAGE, BASE_STORAGE)
	
	set_population_amount(3, true)
	housing_amount = 0
	food_amount = 150
	water_amount = 250
	air_amount = 200
	metal_amount = 100
	morale_amount = 50
	
	# Remove any morale effects
	for _effect in morale_effect_queue:
		var morale_effect = morale_effect_queue.pop_front()
		emit_signal("morale_effect_removed", [morale_effect])
	
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
	current_morale_modifier = 0
	current_officers = [EnumAutoload.Officer.PRESSLEY, EnumAutoload.Officer.TORGON]
	current_upgrades = []
	update_specialist_bonus()


# RESOURCE SETTERS

# POPULATION/CREW-RELATED RESOURCES

func get_population_amount():
	return _population_amount

func set_population_amount(value: int, ignore_morale: bool = false, custom_effect_msg: String = ""):
	var diff = value - _population_amount
	_population_amount = value
	# Signal for UI updates
	emit_signal("population_changed", _population_amount)
	# FIXME - This is probably gonna cause a negative worker number if
	# we lose pop mid-construction
	worker_amount += diff
	available_housing += diff
	# Crew systems
	CrewmateManager.update_current_crewmates(value)
	# Morale impact
	if not ignore_morale:
		var effect_message: String
		if diff < 0:
			if custom_effect_msg:
				effect_message = custom_effect_msg
			else:
				effect_message = "Lost %s crew" % [diff]
			add_morale_effect(
				effect_message, crew_loss_morale_impact * diff, 10
			)
		elif diff > 0:
			if custom_effect_msg:
				effect_message = custom_effect_msg
			else:
				effect_message = "Gained %s crew" % [diff]
			add_morale_effect(
				effect_message, crew_gain_morale_impact * diff, 6
			)
	# Update UI
	update_resource_modifiers()

func set_worker_amount(value: int):
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
			var cancel_method: Callable
			if most_recent_building.is_constructing:
				cancel_method = most_recent_building.cancel_building
			elif most_recent_building.is_deconstructing:
				cancel_method = most_recent_building.cancel_building_remove
			else:
				push_error("No valid construction callable for %s." % [most_recent_building])
			cancel_method.call(true)
			emit_signal("construction_cancelled_lack_of_workers", most_recent_building.data.name)
			
		# Assign the new value
		value += worker_refund
	
	worker_amount = value
	emit_signal("workers_changed", worker_amount)

# HOUSING

func set_housing_amount(value: int):
	housing_amount = value
	emit_signal("housing_changed", housing_amount, available_housing)

func set_available_housing(value: int):
	if value == available_housing:
		return
	available_housing = value
	habitability = calculate_habitability_score()
	update_resource_modifiers()

# MORALE

func set_habitability(value: int):
	habitability = clamp(value, 0, 100)
	morale_amount = habitability + current_morale_modifier

func add_morale_effect(
	_name: String, value: int, length: int, 
	type: MoraleEffect.TYPES = MoraleEffect.TYPES.TemporaryMoraleEffect
):
	# Don't add any effects added before the game starts
	var effect = MoraleEffect.new()
	effect._name = _name
	effect.type = type
	effect.morale_modifier_value = value
	effect.effect_length = length
	TickManager.tick.connect(effect._on_tick)
	
	morale_effect_queue.append(effect)
	update_resource_modifiers()
	emit_signal("morale_effect_applied", [effect])

func remove_morale_effect(effect: MoraleEffect):
	var idx = morale_effect_queue.find(effect)
	if idx == -1:
		return
	var effect_to_remove = morale_effect_queue.pop_at(idx)
	emit_signal("morale_effect_removed", [effect_to_remove])
	emit_signal("morale_changed", morale_amount)

func set_current_morale_modifier(value: int):
	current_morale_modifier = value
	morale_amount = habitability + current_morale_modifier

func set_morale_amount(value: int):
	morale_amount = clamp(value, 0, 100)
	emit_signal("morale_changed", morale_amount)

func set_is_mutiny(value: bool):
	if value == is_mutiny:
		return
	is_mutiny = value
	emit_signal("mutiny", mutiny_time)

func set_mutiny_time_left(value: int):
	mutiny_time_left = value
	if morale_amount == 0:
		emit_signal("mutiny", mutiny_time_left)
		if mutiny_time_left == 0:
			emit_signal("game_over", EnumAutoload.ResourceType.MORALE)

# FOOD

func set_food_amount(value: int):
	food_amount = value
	emit_signal("food_changed", food_amount)

func set_is_starving(value: bool):
	if value == is_starving:
		return
	is_starving = value
	emit_signal("starving", starving_time)

func set_starving_time_left(value: int):
	starving_time_left = value
	if is_starving:
		emit_signal("starving", starving_time_left)
		if starving_time_left == 0:
			emit_signal("game_over", EnumAutoload.ResourceType.FOOD)

# WATER

func set_water_amount(value: int):
	water_amount = value
	emit_signal("water_changed", water_amount)

func set_is_thirsty(value: bool):
	if value == is_thirsty:
		return
	is_thirsty = value
	emit_signal("dehydrated", thirsty_time)

func set_thirsty_time_left(value: int):
	thirsty_time_left = value
	if is_thirsty:
		emit_signal("dehydrated", thirsty_time_left)
		if thirsty_time_left == 0:
			emit_signal("game_over", EnumAutoload.ResourceType.WATER)

# AIR

func set_air_amount(value: int):
	air_amount = value
	emit_signal("air_changed", air_amount)

func set_is_suffocating(value: bool):
	if value == is_suffocating:
		return
	is_suffocating = value
	emit_signal("suffocating", suffocating_time)

func set_suffocating_time_left(value: int):
	suffocating_time_left = value
	if is_suffocating:
		emit_signal("suffocating", suffocating_time_left)
		if suffocating_time_left == 0:
			emit_signal("game_over", EnumAutoload.ResourceType.AIR)

# METAL

func set_metal_amount(value: int):
	metal_amount = value
	emit_signal("metal_changed", metal_amount)
