static func check_if_enough_resource(cost: ResourceCost) -> bool:
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


static func apply_resource_cost(cost: ResourceCost) -> void:
    # return
    ResourceManager.food_amount -= cost.food
    ResourceManager.water_amount -= cost.water
    ResourceManager.air_amount -= cost.air
    ResourceManager.metal_amount -= cost.metal


static func calculate_build_time_with_upgrade(base_time: int) -> int:
    var reduction_perc = 0
    if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_CREW_CHIEF in ResourceManager.current_upgrades:
        reduction_perc += 0.1
    if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_DEEP_SPACE in ResourceManager.current_upgrades:
        reduction_perc += 0.15
    if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_DRONE in ResourceManager.current_upgrades:
        reduction_perc += 0.25
    return ceil(base_time * (1 - reduction_perc))
    
    
static func calculate_build_cost_with_upgrade(base_cost: int) ->int:
    var reduction_perc = 0
    if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_IMPROVE_SCHEMATICS in ResourceManager.current_upgrades:
        reduction_perc += 0.1
    if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_AI_ENHANCED_SCHEMATICS in ResourceManager.current_upgrades:
        reduction_perc += 0.15
    if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_AI_GENERATED_SCHEMATICS in ResourceManager.current_upgrades:
        reduction_perc += 0.25
    return ceil(base_cost * (1 - reduction_perc))