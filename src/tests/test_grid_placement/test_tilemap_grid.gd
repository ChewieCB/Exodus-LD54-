extends Node2D

@onready var tilemap = $TileMap
var building = preload("res://src/tests/test_grid_placement/test_building.tscn")
var mouse_pos: Vector2
var placement_pos: Vector2
var preview_pos: Vector2
var current_building: Node
var previous_rotation = 0


func _ready():
	get_new_building()


func get_new_building():
	var new_building = building.instantiate()
	new_building.preview = true
	new_building.rotation = previous_rotation
	add_child(new_building)
	current_building = new_building


func _physics_process(_delta):
	mouse_pos = get_global_mouse_position()
	mouse_pos = tilemap.to_local(mouse_pos)
	placement_pos = tilemap.local_to_map(mouse_pos)
	preview_pos = tilemap.map_to_local(placement_pos) + Vector2(32, 32)
	preview_pos = tilemap.to_global(preview_pos)
	if current_building:
		current_building.global_position = preview_pos

		if Input.is_action_just_pressed("place_building"):
			if not current_building.collider.has_overlapping_areas():
				place_building()

		if Input.is_action_just_pressed("rotate_cw"):
			current_building.rotation += PI/2
		elif Input.is_action_just_pressed("rotate_ccw"):
			current_building.rotation -= PI/2


func place_building():
	current_building.preview = false
	previous_rotation = current_building.rotation
	current_building = null
	get_new_building()
