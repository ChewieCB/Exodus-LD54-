static func check_if_enough_resource(cost: ResourceData) -> bool:
	# return true
	if ResourceManager.food_amount < cost.food:
		return false
	if ResourceManager.water_amount < cost.water:
		return false
	if ResourceManager.air_amount < cost.air:
		return false
	if ResourceManager.metal_amount < cost.metal:
		return false
	return true


static func change_resource(resource_data: ResourceData, add: bool = true, multiplier: float = 1) -> void:
	var operation_multiplier = 1
	if not add:
		operation_multiplier = -1
	ResourceManager.food_amount += ceil(resource_data.food * operation_multiplier * multiplier)
	ResourceManager.water_amount += ceil(resource_data.water * operation_multiplier * multiplier)
	ResourceManager.air_amount += ceil(resource_data.air * operation_multiplier * multiplier)
	ResourceManager.metal_amount += ceil(resource_data.metal * operation_multiplier * multiplier)


static func get_build_time_with_upgrade_multiplier() -> float:
	var reduction_perc = 0
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_CREW_CHIEF in ResourceManager.current_upgrades:
		reduction_perc += 0.1
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_DEEP_SPACE in ResourceManager.current_upgrades:
		reduction_perc += 0.15
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_DRONE in ResourceManager.current_upgrades:
		reduction_perc += 0.25
	return clampf(1 - reduction_perc, 0, 1)
	
static func calculate_build_time_with_upgrade(base_time: int) -> int:
	var reduction_perc = get_build_time_with_upgrade_multiplier()
	return ceil(base_time * (1 - reduction_perc))


static func get_build_cost_with_upgrade_multiplier() -> float:
	var reduction_perc = 0
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_IMPROVE_SCHEMATICS in ResourceManager.current_upgrades:
		reduction_perc += 0.1
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_AI_ENHANCED_SCHEMATICS in ResourceManager.current_upgrades:
		reduction_perc += 0.15
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_AI_GENERATED_SCHEMATICS in ResourceManager.current_upgrades:
		reduction_perc += 0.25
	return clampf(1 - reduction_perc, 0, 1)

static func calculate_build_cost_with_upgrade(base_cost: int) -> int:
	var reduction_perc = get_build_cost_with_upgrade_multiplier()
	return ceil(base_cost * (1 - reduction_perc))


static func get_storage_with_upgrade_multiplier() -> float:
	var bonus_perc = 0
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_ADV_SORTERS in ResourceManager.current_upgrades:
		bonus_perc += 0.25
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_AUTOMATED_WAREHOUSES in ResourceManager.current_upgrades:
		bonus_perc += 0.50
	return (1 + bonus_perc)

static func calculate_storage_with_upgrade(base_storage: int) -> int:
	var bonus_perc = get_storage_with_upgrade_multiplier()
	return ceil(base_storage * (1 + bonus_perc))