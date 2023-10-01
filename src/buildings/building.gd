extends Node2D
class_name Building

@export var data: Resource
@onready var type = data.type

@onready var sprite = $Sprite2D
@onready var collider = $Area2D
@onready var debug_label = $Debug

# Build menu vars
var preview = false
var outside_gridmap = false
var original_color: Color
var placeable = false
var placed = false

enum TYPES {
	HabBuilding,
	FoodBuilding,
	WaterBuilding,
	AirBuilding
}


func _ready():
#	sprite.texture = data.sprite
#	collider = data.collision_data
	set_original_color()
	debug_label.text = "DEBUG DATA\nH: {0}\tF: {1}\tW: {2}\tA: {3}".format(
		[data.housing_prod, data.food_prod, data.water_prod, data.air_prod]
	)


func _process(delta):
	if not placed and preview:
		if collider.has_overlapping_areas() or collider.has_overlapping_bodies() or outside_gridmap:
			color_sprite(1, 0, 0, 0.5)
			placeable = false
		else:
			color_sprite(0, 1, 0, 0.5)
			placeable = true


func set_building_placed():
	placed = true
	preview = false
	color_sprite(original_color.r, original_color.g, original_color.b, original_color.a)


func set_original_color():
	if sprite is Sprite2D:
		original_color = sprite.self_modulate
	elif sprite is Node2D and sprite.get_child_count() > 0:
		original_color = sprite.get_children()[0].self_modulate


func color_sprite(r, g, b, a):
	if sprite is Sprite2D:
		sprite.self_modulate = Color(r, g, b, a)
	elif sprite is Node2D and sprite.get_child_count() > 0:
		# This is a group of rectangle, used in testing only
		for item in sprite.get_children():
			item.self_modulate = Color(r, g, b, a)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			on_predelete()


func on_predelete() -> void:
	ResourceManager.remove_building(self)

