extends Resource

@export_group("Display")
@export var name: String
@export var type: Building.TYPES
@export var sprite: Texture2D
@export var collision_data: Array[CollisionShape2D]
@export_group("Economy")
@export var housing_prod: int
@export var food_prod: int
@export var water_prod: int
@export var air_prod: int
@export_group("Construction")
@export_subgroup("Building")
@export var resource_cost: int
@export var resource_type: Node
@export var people_cost: int
@export var people_type: Node
@export_subgroup("Destroying")
@export var refund_value: int
@export var refund_resource: Node
@export_subgroup("Timings")
@export var construction_time: float
@export var destruction_time: float


func _init(
	p_name = "BUILDING_NAME_MISSING", p_type = Building.TYPES.HabBuilding,
	p_sprite = null, p_collision_data = [],
	p_housing_prod = 0, p_food_prod = 0, p_water_prod = 0, p_air_prod = 0,
	p_resource_cost = 0, p_resource_type = null, p_people_cost = 0, p_people_type = null,
	p_refund_value = 0, p_refund_resource = null, p_construction_time = 0, p_destruction_time = 0
):
	housing_prod = p_housing_prod
	food_prod = p_food_prod
	water_prod = p_water_prod
	air_prod = p_air_prod
	resource_cost = p_resource_cost
	resource_type = p_resource_type
	people_cost = p_people_cost
	people_type = p_people_type
	refund_value = p_refund_value
	refund_resource = p_refund_resource
	construction_time = p_construction_time
	destruction_time = p_destruction_time

