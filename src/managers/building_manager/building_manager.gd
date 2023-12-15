extends Node

signal building_selected(building: PackedScene)
signal not_enough_workers
signal not_enough_resource
signal show_info_panel(pos: Vector2, building: Building)
signal hide_info_panel
signal building_finished
signal building_deconstructed

# Array to store each building under construction in order from most recent
# to least recent, used so we can cancel construction and refund remaining workers
# when pop goes down.
var construction_queue = []
var buildings: Array[Building] = []
var n_hab_building = 0
var n_food_building = 0
var n_water_building = 0
var n_air_building = 0

# Use an array to avoid race condition
var selected_building_queue: Array[Building] = []

func _input(event):
	if event.is_action_pressed("left_click"):
		if len(selected_building_queue) > 0 and not selected_building_queue[0].preview:
			show_building_info_panel(selected_building_queue[0].global_position, selected_building_queue[0])


func start_building(building_scene):
	emit_signal("building_selected", building_scene)

func show_building_info_panel(pos: Vector2, building: Building):
	emit_signal("show_info_panel", pos, building)

func hide_building_info_panel():
	emit_signal("hide_info_panel")

func check_if_building_exist(building_name: String) -> bool:
	for b in buildings:
		if b.name == building_name:
			return true
	return false

func delete_building_with_name(building_name: String) -> bool:
	""" Return true if success. building_name is object name """
	for b in buildings:
		if b.name == building_name:
			buildings.erase(b)
			b.remove_building()
			return true
	return false

func finished_building(type: EnumAutoload.BuildingType):
	emit_signal("building_finished", type)
	match type:
		EnumAutoload.BuildingType.HABITATION:
			n_hab_building += 1
		EnumAutoload.BuildingType.FOOD:
			n_food_building += 1
		EnumAutoload.BuildingType.WATER:
			n_water_building += 1
		EnumAutoload.BuildingType.AIR:
			n_air_building += 1
		EnumAutoload.BuildingType.METAL:
			n_air_building += 1


func expand_building_area(blockoff_name: String):
	var ship_building_view = get_tree().get_root().get_node("ShipBuildingView")
	var ship_grid = ship_building_view.get_node("ShipSprite/ShipGrid")
	var blockoff_area = ship_grid.get_node(blockoff_name)
	blockoff_area.process_mode = PROCESS_MODE_DISABLED
	blockoff_area.visible = false


func reset_state():
	n_hab_building = 0
	n_food_building = 0
	n_water_building = 0
	n_air_building = 0
	buildings = []
	construction_queue = []
