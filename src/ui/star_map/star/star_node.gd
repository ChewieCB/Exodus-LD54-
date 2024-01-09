extends Node2D
class_name StarNode

signal star_selected(star)
signal queue_star_selected(star)

@onready var goal_highlight = $Highlight

@onready var star_red_scene = load("res://assets/planets/Star/StarRed.tscn")
@onready var star_orange_scene = load("res://assets/planets/Star/StarOrange.tscn")
@onready var star_yellow_scene = load("res://assets/planets/Star/StarYellow.tscn")
@onready var star_white_scene = load("res://assets/planets/Star/StarWhite.tscn")
@onready var star_blue_scene = load("res://assets/planets/Star/StarBlue.tscn")
@onready var star_colours = [
	star_red_scene, star_orange_scene, star_yellow_scene,
	star_white_scene, star_blue_scene
]
# We choose a star colour on init of this scene
var star_scene

var star_instance = null
var star_attributes = {}
var star_seed: int = 0
var star_size: float = 30.0
var star_rotation: float = 1.40
var star_tiles: int = 5
var star_time: float = 0.0
var star_timespeed: float = 0.3

var is_goal: bool = false: # For checking game end
	set(value):
		is_goal = value

var pickable: bool = false:
	set(value):
		pickable = value
		if star_instance != null:
			star_instance._highlight.visible = pickable


var has_signal: bool = false:
	set(value):
		has_signal = value
		if star_instance != null:
			star_instance._signal.visible = has_signal

var connected_event: ExodusEvent:
	set(value):
		connected_event = value
		has_signal = true


func _ready():
	var star_colour_idx = randi_range(0, 4)
	star_scene = star_colours[star_colour_idx]


func _input(event):
	if pickable:
#		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
#			has_signal = !has_signal
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if Input.is_action_pressed("shift"):
				emit_signal("queue_star_selected", self)
			else:
				emit_signal("star_selected", self)


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
	
#	get_parent().get_parent().star_shaders_visible += 1
	add_child(star_instance)
	star_instance._signal.visible = has_signal


func _on_visible_on_screen_notifier_2d_screen_exited():
	star_instance.queue_free()
#	get_parent().get_parent().star_shaders_visible -= 1


func _on_area_2d_mouse_entered():
	pickable = true


func _on_area_2d_mouse_exited():
	pickable = false

