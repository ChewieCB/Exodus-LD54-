extends Building
class_name WarehouseBuilding

@onready var adjacent_range: Area2D = $Range
@onready var adjacent_range_sprite: Sprite2D = $Range/RangeSprite


var specialized_type: EnumAutoload.ResourceType = EnumAutoload.ResourceType.NONE

const SPEC_STORAGE_MULTIPLIER = 4
const SPEC_PROD_BONUS = 1
const BASE_PROD_BONUS = 0.2

const SPEC_COLOR = [
	Color(1, 1, 1), # None
	null, # Population
	null, # Storage
	null, # Housing
	null, # Morale
	Color(0.4, 1, 0.4), # Food
	Color(0.4, 0.8, 1), # Water
	Color(1, 0.4, 0.4), # Air
	Color(0.7, 0.9, 0.7) # Metal
]

func _ready():
	super()
	data.type = EnumAutoload.BuildingType.STORAGE


func apply_upgrades():
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_ADV_LOGISTIC in ResourceManager.current_upgrades:
		adjacent_range.scale = Vector2(1.5, 1.5)
	# Wait 2 frame to make sure all Area2D changes are setup correctly
	await get_tree().physics_frame
	await get_tree().physics_frame
	check_for_adjacency_multiplier(data.type)

func set_specialisation(_type: EnumAutoload.ResourceType):
	specialized_type = _type
	sprite.self_modulate = SPEC_COLOR[specialized_type]
	# Force emit signal so we can update other buildings bonus multiplier
	BuildingManager.finished_building(EnumAutoload.BuildingType.NONE)

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
		adjacent_range_sprite.visible = true

func remove_improved_preview():
	adjacent_range_sprite.visible = false

func get_context_menu_name() -> String:
	var tmp = ""
	match specialized_type:
		EnumAutoload.ResourceType.AIR:
			tmp = "Oxygen "
		EnumAutoload.ResourceType.WATER:
			tmp = "Water "
		EnumAutoload.ResourceType.FOOD:
			tmp = "Food "
		EnumAutoload.ResourceType.METAL:
			tmp = "Metal "
	return tmp + data.name

func get_context_menu_description() -> String:
	var tmp = ""
	# Note: Specialize upgrade always get after the adjacent bonus upgrade so we don't need to check
	match specialized_type:
		EnumAutoload.ResourceType.AIR:
			tmp = "Increased max storage capacity for Oxygen by {n_storage} units.".format({"n_storage": ResourceManager.calculate_storage_with_upgrade(get_resource_storage_capacity().air)})
			tmp += "\nGive 100% bonus production to nearby Oxygen-producing buildings."
		EnumAutoload.ResourceType.WATER:
			tmp = "Increased max storage capacity for Water by {n_storage} units.".format({"n_storage": ResourceManager.calculate_storage_with_upgrade(get_resource_storage_capacity().water)})
			tmp += "\nGive 100% bonus production to nearby Water-producing buildings."
		EnumAutoload.ResourceType.FOOD:
			tmp = "Increased max storage capacity for Food by {n_storage} units.".format({"n_storage": ResourceManager.calculate_storage_with_upgrade(get_resource_storage_capacity().food)})
			tmp += "\nGive 100% bonus production to nearby Food-producing buildings."
		EnumAutoload.ResourceType.METAL:
			tmp = "Increased max storage capacity for Metal by {n_storage} units.".format({"n_storage": ResourceManager.calculate_storage_with_upgrade(get_resource_storage_capacity().metal)})
			tmp += "\nGive 100% bonus production to nearby Metal-producing buildings."
		EnumAutoload.BuildingType.NONE:
			tmp = "Increased max storage capacity for all resources by {n_storage} units.".format({"n_storage": ResourceManager.calculate_storage_with_upgrade(data.storage_prod)})
			if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_STOCK_ANALYSIS in ResourceManager.current_upgrades:
				tmp += "\nGive 20% bonus production to nearby resource-producing buildings."
	tmp += '\nWarning: Desconstruct this building will cause surplus resources to be lost.'
	return tmp

func check_condition_for_specialize():
	if not building_complete or is_deconstructing or is_constructing:
		return false
	if specialized_type != EnumAutoload.ResourceType.NONE:
		return false
	if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_SPECIALIZED_WAREHOUSE not in ResourceManager.current_upgrades:
		return false
	return true
