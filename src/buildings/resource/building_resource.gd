extends Resource
class_name BuildingResource

@export_group("Display")
@export var name: String
@export var type: Building.TYPES
@export var sprite: Texture2D
@export var collision_data: CollisionShape2D
@export_group("Economy")
@export var housing_prod: int
@export var food_prod: int
@export var water_prod: int
@export var air_prod: int
@export var metal_prod: int
@export_group("Construction")
@export_subgroup("Building")
@export var food_cost: int
@export var air_cost: int
@export var water_cost: int
@export var metal_cost: int
@export var people_cost: int # required for building. Will be refund after finished building
@export_subgroup("Destroying")
@export var refund_food: int
@export var refund_air: int
@export var refund_water: int
@export var refund_metal: int
@export var refund_population: int # Exclusive to CRYO POD type building
@export_subgroup("Timings")
@export var construction_time: int
@export var destruction_time: int


func _init(
	p_name = "BUILDING_NAME_MISSING", p_type = Building.TYPES.HabBuilding,
	p_sprite = null, p_collision_data = [],
	p_housing_prod = 0, p_food_prod = 0, p_water_prod = 0, p_air_prod = 0,
	p_people_cost = 0, p_construction_time = 0, p_destruction_time = 0
):
	housing_prod = p_housing_prod
	food_prod = p_food_prod
	water_prod = p_water_prod
	air_prod = p_air_prod
	people_cost = p_people_cost
	construction_time = p_construction_time
	destruction_time = p_destruction_time

