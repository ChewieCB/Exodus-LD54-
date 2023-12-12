extends Building
class_name WarehouseBuilding

var specialized_type: EnumAutoload.ResourceType = EnumAutoload.ResourceType.NONE

const SPEC_STORAGE_MULTIPLIER = 4
const SPEC_PROD_BONUS = 1
const BASE_PROD_BONUS = 0.2

func _ready():
    super()
    type = EnumAutoload.ResourceType.STORAGE


func apply_upgrades():
    if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_ADV_LOGISTIC in ResourceManager.current_upgrades:
            get_node("Range").scale = Vector2(1.5, 1.5)
    # Wait 2 frame to make sure all Area2D changes are setup correctly
    await get_tree().physics_frame
    await get_tree().physics_frame
    check_for_adjacency_multiplier(type)

func set_specialisation(_type: EnumAutoload.ResourceType):
    specialized_type = _type

func get_resource_bonus_prod():
    var resource_data = {"air": 0, "water": 0, "food": 0, "metal": 0}
    match specialized_type:
        EnumAutoload.ResourceType.AIR:
            resource_data.air = SPEC_PROD_BONUS
        EnumAutoload.ResourceType.WATER:
            resource_data.water = SPEC_PROD_BONUS
        EnumAutoload.ResourceType.FOOD:
            resource_data.food = SPEC_PROD_BONUS
        EnumAutoload.ResourceType.METAL:
            resource_data.metal = SPEC_PROD_BONUS
        EnumAutoload.ResourceType.NONE:
            resource_data.water = BASE_PROD_BONUS
            resource_data.food = BASE_PROD_BONUS
            resource_data.metal = BASE_PROD_BONUS
            resource_data.air = BASE_PROD_BONUS
    return resource_data


func get_resource_storage_capacity():
    var resource_data = {"air": 0, "water": 0, "food": 0, "metal": 0}
    var base_capacity = data.storage_prod
    match specialized_type:
        EnumAutoload.ResourceType.AIR:
            resource_data.air = base_capacity * SPEC_STORAGE_MULTIPLIER
        EnumAutoload.ResourceType.WATER:
            resource_data.water = base_capacity * SPEC_STORAGE_MULTIPLIER
        EnumAutoload.ResourceType.FOOD:
            resource_data.food = base_capacity * SPEC_STORAGE_MULTIPLIER
        EnumAutoload.ResourceType.METAL:
            resource_data.metal = base_capacity * SPEC_STORAGE_MULTIPLIER
        EnumAutoload.ResourceType.NONE:
            resource_data.water = base_capacity
            resource_data.food = base_capacity
            resource_data.metal = base_capacity
            resource_data.air = base_capacity
    return resource_data



func enable_improved_preview():
    if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_STOCK_ANALYSIS in ResourceManager.current_upgrades:
        get_node("Range/RangeSprite").visible = true

func remove_improved_preview():
    get_node("Range/RangeSprite").visible = false