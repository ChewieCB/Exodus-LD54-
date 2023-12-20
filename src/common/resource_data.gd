extends Resource
class_name ResourceData

@export var food: int
@export var water: int
@export var air: int
@export var metal: int

func _init(p_food = 0, p_water = 0, p_air = 0, p_metal = 0):
    food = p_food
    water = p_water
    air = p_air
    metal = p_metal
