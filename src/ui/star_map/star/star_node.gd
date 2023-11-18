extends Node2D

@onready var star_scene = load("res://assets/planets/Star/Star.tscn")
var star_instance = null
var star_attributes = null # TODO - cache these on generation so stars render consistently


func _on_visible_on_screen_notifier_2d_screen_entered():
	star_instance = star_scene.instantiate()
	add_child(star_instance)
	get_parent().star_shaders_visible += 1


func _on_visible_on_screen_notifier_2d_screen_exited():
	star_instance.queue_free()
	get_parent().star_shaders_visible -= 1
