extends Resource
class_name BuildingResource

@export_group("Display")
@export var name: String
@export var type: EnumAutoload.BuildingType
@export var sprite: Texture2D
@export_group("Production")
@export var resource_prod: ResourceData
@export var housing_prod: int
@export var storage_prod: int
@export_group("Construction")
@export var resource_cost: ResourceData
@export var people_cost: int # required for building. Will be refunded after finished building
@export var refund_population: int # Exclusive to CRYO POD type building
@export var construction_time: int
@export var destruction_time: int

