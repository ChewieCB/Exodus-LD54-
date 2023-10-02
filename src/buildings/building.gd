extends Node2D
class_name Building

@export var data: Resource
@onready var type = data.type

@onready var sprite = $Sprite2D
@onready var collider = $Area2D
@onready var build_timer_ui = $BuildTimerUI

@onready var pulse_shader = preload("res://src/buildings/shaders/pulse.gdshader")

@onready var build_start_sfx = preload("res://assets/audio/sfx/Building_Start.mp3")
@onready var build_finish_sfx = preload("res://assets/audio/sfx/Building_Finish.mp3")

# Build menu vars
var preview = false
var outside_gridmap = false
var original_color: Color
var placeable = false
var placed = false

# Building process vars
var ticks_left_to_build: int
var building_complete: bool = false

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
	build_timer_ui.visible = false
	TickManager.tick.connect(_on_tick)
	


func build_in_progress():
	# Update the building to show it's under construction
	var pulse_colour = Color("#ffd4a3")
	pulse_colour.a = 0.5
	var pulse_mat = ShaderMaterial.new()
	pulse_mat.shader = pulse_shader
	sprite.material = pulse_mat
	sprite.material.set_shader_parameter("shine_color", pulse_colour)
	sprite.material.set_shader_parameter("full_pulse_cycle", true)
	sprite.material.set_shader_parameter("mode", 1)


func _process(delta):
	if not placed and preview:
		if collider.has_overlapping_areas() or collider.has_overlapping_bodies() or outside_gridmap:
			color_sprite(1, 0, 0, 0.5)
			placeable = false
		else:
			color_sprite(0, 1, 0, 0.5)
			placeable = true


func _on_tick():
	if not placed:
		return
	if not building_complete:
		if ticks_left_to_build <= 1:
			building_complete = true
			build_timer_ui.visible = false
			sprite.material.set_shader_parameter("mode", 0)
			ResourceManager.add_building(self)
			ResourceManager.retrieve_workers(self)
			SoundManager.play_sound(build_finish_sfx, "SFX")
		else:
			ticks_left_to_build -= 1
			build_timer_ui.label.text = str(ticks_left_to_build)


func set_building_placed():
	placed = true
	preview = false
	#
	ResourceManager.assign_workers(self)
	# Restore the building's true colour outside of preview UI
	color_sprite(original_color.r, original_color.g, original_color.b, original_color.a)
	# Update build timer/construction effects
	ticks_left_to_build = data.construction_time
	build_timer_ui.label.text = str(ticks_left_to_build)
	build_timer_ui.visible = true
	build_in_progress()
	SoundManager.play_sound(build_start_sfx, "SFX")


func set_original_color():
	if sprite is Sprite2D:
		original_color = sprite.modulate
	elif sprite is Node2D and sprite.get_child_count() > 0:
		original_color = sprite.get_children()[0].modulate


func color_sprite(r, g, b, a):
	if sprite is Sprite2D:
		sprite.modulate = Color(r, g, b, a)
	elif sprite is Node2D and sprite.get_child_count() > 0:
		# This is a group of rectangle, used in testing only
		for item in sprite.get_children():
			item.modulate = Color(r, g, b, a)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			on_predelete()


func on_predelete() -> void:
	ResourceManager.remove_building(self)

