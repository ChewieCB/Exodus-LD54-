extends Node2D

@onready var star_scene = load("res://assets/planets/Star/Star.tscn")
var star_instance = null
var star_attributes = {}
var star_seed: int = 0
var star_colours: PackedColorArray = [] # TODO - cache these on generation so stars render consistently
var star_size: float = 30.0
var star_rotation: float = 1.40
var star_tiles: int = 5
var star_time: float = 0.0
var star_timespeed: float = 0.3

func _on_visible_on_screen_notifier_2d_screen_entered():
	star_instance = star_scene.instantiate()
	
	if not star_attributes:
		# Seed
		star_seed = randi_range(0, 9999999)
		# Colour - FIXME: All stars change to the same colours
#		star_instance.randomize_colors()
#		star_colours = star_instance.get_colors()
		# Size/shape
		star_size = randf_range(5, 40)
		# Rotation
		star_rotation = randf_range(0.0, 6.28)
		# Tiling
		while star_tiles != 10:
			star_tiles = randi_range(0, 20)
		# Start time
		star_time = randf_range(0, 100)
		# Time Speed
		star_timespeed = randf_range(0.1, 1.0)
		
		# Attributes dict
		star_attributes = {
			"seed": star_seed,
#			"colors": star_colours,
			"size": star_size,
			"rotation": star_rotation,
			"tiles": star_tiles,
			"time": star_time,
			"time_speed": star_timespeed
		}
	
	star_instance.set_seed(star_attributes["seed"])
#	star_instance.set_colors(star_attributes["colors"])
	# Set other params
	for _param in star_attributes.keys().slice(2):
		star_instance.set_param(_param, star_attributes[_param])
	
	get_parent().get_parent().star_shaders_visible += 1
	add_child(star_instance)


func _on_visible_on_screen_notifier_2d_screen_exited():
	star_instance.queue_free()
	get_parent().get_parent().star_shaders_visible -= 1
