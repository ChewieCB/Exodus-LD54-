static func check_if_enough_resource(cost: ResourceCost) -> bool:
    return true
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
    ResourceManager.food_amount -= cost.food
    ResourceManager.water_amount -= cost.water
    ResourceManager.air_amount -= cost.air
    ResourceManager.metal_amount -= cost.metal