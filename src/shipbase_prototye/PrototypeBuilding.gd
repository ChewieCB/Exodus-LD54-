extends Node2D
class_name BuildingOLD

@onready var sprite = $Sprite
@onready var collider = $Area2D

var preview = false
var outside_gridmap = false
var can_place = true
var original_color: Color

func _ready() -> void:
	set_original_color()


func _process(delta):
	if preview:
		if collider.has_overlapping_areas() or outside_gridmap:
			color_sprite(1, 0, 0, 0.5)
		else:
			color_sprite(0, 1, 0, 0.5)
	else:
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


func _on_area_2d_area_entered(area):
	can_place = false


func _on_area_2d_area_exited(area):
	can_place = true
