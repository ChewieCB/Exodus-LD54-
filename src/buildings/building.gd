extends Node2D
class_name Building

@export var data: Resource
@onready var type = data.type

@onready var sprite = $Sprite2D
@onready var collider = $Area2D/CollisionShape2D

@onready var debug_label = $Debug

enum TYPES {
	HabBuilding,
	FoodBuilding,
	WaterBuilding,
	AirBuilding
}


func _init():
	ResourceManager.add_building(self)


func _ready():
	sprite.texture = data.sprite
	collider = data.collision_data
	debug_label.text = "DEBUG DATA\nH: {0}\tF: {1}\tW: {2}\tA: {3}".format(
		[data.housing_prod, data.food_prod, data.water_prod, data.air_prod]
	)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			on_predelete()


func on_predelete() -> void:
	ResourceManager.remove_building(self)

