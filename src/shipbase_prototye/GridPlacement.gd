extends Node2D
class_name GridPlacement

@export var tilemap: Node
@export var grid_size: Vector2

@export var hab_1: PackedScene
var building

var mouse_pos: Vector2
var placement_coord: Vector2
var preview_pos: Vector2
var current_building: Node
var previous_rotation = 0


func _ready():
	pass


func get_new_building():
	var new_building = building.instantiate()
	new_building.preview = true
	new_building.rotation = previous_rotation
	new_building.visible = true
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
		current_building.outside_gridmap = is_outside_gridmap(placement_coord)
		current_building.visible = !current_building.outside_gridmap
		current_building.global_position = preview_pos
		
		if Input.is_action_just_pressed("ui_cancel"):
			current_building.queue_free()
			current_building = null

		if Input.is_action_just_pressed("place_building"):
			if not current_building.collider.has_overlapping_areas():
				if not is_outside_gridmap(placement_coord):
					place_building()

		if Input.is_action_just_pressed("rotate_cw"):
			current_building.rotation += PI/2
		elif Input.is_action_just_pressed("rotate_ccw"):
			current_building.rotation -= PI/2


func is_outside_gridmap(coord: Vector2) -> bool:
	print(tilemap.get_cell_source_id(0, coord))
	if tilemap.get_cell_source_id(0, coord) == -1:
		return true
	else:
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


func _on_hab_1_button_pressed():
	building = hab_1
	stop_building_preview()
	get_new_building()
