extends Node2D

@onready var sprite = $Sprite2D
@onready var collider = $Area2D

var preview = false
var can_place = true


func _process(delta):
	if preview:
		sprite.modulate.a = 0.5
		if collider.has_overlapping_areas():
			sprite.modulate.r = 1
			sprite.modulate.g = 0
			sprite.modulate.b = 0
		else:
			sprite.modulate.r = 0
			sprite.modulate.g = 1
			sprite.modulate.b = 0
	else:
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		






func _on_area_2d_area_entered(area):
	can_place = false


func _on_area_2d_area_exited(area):
	can_place = true
