extends Node2D
class_name GridPlacement

@onready var tilemap = $TileMap
@export var grid_size: Vector2

var building
var mouse_pos: Vector2
var placement_coord: Vector2
var preview_pos: Vector2
var current_building: Node
var previous_rotation = 0


func _ready():
	pass


func get_new_building():
	var new_building: Building = building.instantiate()
	new_building.preview = true
	new_building.rotation = previous_rotation
	new_building.visible = false
	add_child(new_building)
	current_building = new_building


func _physics_process(_delta):
	if building == null or current_building == null:
		return

	mouse_pos = get_global_mouse_position()
	mouse_pos = tilemap.to_local(mouse_pos)
	placement_coord = tilemap.local_to_map(mouse_pos)
	preview_pos = tilemap.map_to_local(placement_coord) + Vector2(32, 32)
	preview_pos = tilemap.to_global(preview_pos)

	if current_building:
		current_building.visible = true
		current_building.outside_gridmap = check_if_outside_gridmap(placement_coord)
		current_building.global_position = preview_pos

		if Input.is_action_just_pressed("place_building"):
			if not current_building.collider.has_overlapping_areas():
				if not check_if_outside_gridmap(placement_coord):
					place_building()

		if Input.is_action_just_pressed("rotate_cw"):
			current_building.rotation += PI/2
		elif Input.is_action_just_pressed("rotate_ccw"):
			current_building.rotation -= PI/2


func check_if_outside_gridmap(coord: Vector2) -> bool:
	if placement_coord.x < 0 or placement_coord.y < 0 \
		or placement_coord.x >= grid_size.x or placement_coord.y >= grid_size.y:
		return true
	return false



func place_building():
	current_building.preview = false
	previous_rotation = current_building.rotation
	current_building = null
	get_new_building()


func stop_building_preview():
	if current_building != null:
		previous_rotation = current_building.rotation
		current_building.queue_free()
		current_building = null
