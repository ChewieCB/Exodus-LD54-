extends Node2D
class_name GridPlacement

@export var tilemap: TileMap

var building_prefab: PackedScene
var mouse_pos: Vector2
var placement_coord: Vector2 # Will be modified to make preview fit better
var original_placement_coord: Vector2 # Actual tile the mouse pointer is on
var preview_pos: Vector2
var current_building: Node
var previous_rotation = 0
var rotate_counter = 0

@onready var cant_place_sfx = preload("res://assets/audio/sfx/Cant_Place_Building_There.mp3")


func _ready():
	BuildingManager.building_selected.connect(_building_button_pressed)
	assign_pre_placed_buildings()


func assign_pre_placed_buildings() -> void:
	for child in get_children():
		if child is Building:
			ResourceManager.add_building(child)


func get_new_building():
	var new_building = building_prefab.instantiate()
	new_building.preview = true
	new_building.rotation = previous_rotation
	new_building.visible = true
	add_child(new_building)
	current_building = new_building


func _physics_process(_delta):
	if building_prefab == null or current_building == null:
		return

	mouse_pos = get_global_mouse_position()
	mouse_pos = tilemap.to_local(mouse_pos)
	placement_coord = tilemap.local_to_map(mouse_pos)
	original_placement_coord = placement_coord
	if abs(rotate_counter) % 4 == 1:
		placement_coord.x -= 1
	elif abs(rotate_counter) % 4 == 2:
		placement_coord -= Vector2(1, 1)
	elif abs(rotate_counter) % 4 == 3:
		placement_coord.y -= 1
	preview_pos = tilemap.map_to_local(placement_coord) + Vector2(32, 32)
	preview_pos = tilemap.to_global(preview_pos)

	if current_building:
		current_building.outside_gridmap = is_outside_gridmap(original_placement_coord)
		current_building.visible = !current_building.outside_gridmap
		current_building.global_position = preview_pos

		if Input.is_action_just_pressed("cancel_place_building"):
			current_building.queue_free()
			current_building = null

		if Input.is_action_just_released("place_building"):
			if not current_building.collider.has_overlapping_areas():
				if not is_in_blocked_tile(original_placement_coord):
					if current_building.placeable:
						place_building()
			else:
				SoundManager.play_sound(cant_place_sfx, "SFX")

		if Input.is_action_just_pressed("rotate_cw"):
			current_building.rotation += PI/2
			rotate_counter += 1
		elif Input.is_action_just_pressed("rotate_ccw"):
			current_building.rotation -= PI/2
			rotate_counter -= 1


func is_outside_gridmap(coord: Vector2) -> bool:
	if tilemap.get_cell_source_id(0, coord) == -1:
		return true
	else:
		return false


func is_in_blocked_tile(coord: Vector2) -> bool:
	if tilemap.get_cell_atlas_coords(0, coord) == Vector2i(4, 7) or \
		tilemap.get_cell_atlas_coords(0, coord) == Vector2i(-1, -1):
		return true
	else:
		return false

func place_building():
	if ResourceManager.worker_amount < current_building.data.people_cost:
		BuildingManager.emit_signal("not_enough_workers")
		SoundManager.play_sound(cant_place_sfx, "SFX")
		return
	if ResourceManager.metal_amount < current_building.data.metal_cost:
		BuildingManager.emit_signal("not_enough_metal")
		SoundManager.play_sound(cant_place_sfx, "SFX")
		return

	current_building.set_building_placed()
	var tmp_building = current_building
	previous_rotation = current_building.rotation
	current_building.build_timer_ui.update_rotation()
	current_building = null

func stop_building_preview():
	if current_building != null:
		previous_rotation = current_building.rotation
		current_building.queue_free()
		current_building = null


func _building_button_pressed(_building: PackedScene):
	building_prefab = _building
	stop_building_preview()
	get_new_building()
