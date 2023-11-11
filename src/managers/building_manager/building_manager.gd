extends Node

signal building_selected(building: PackedScene)
signal not_enough_workers
signal not_enough_metal
signal show_info_panel(pos: Vector2, data: BuildingResource)
signal hide_info_panel

# Array to store each building under construction in order from most recent
# to least recent, used so we can cancel construction and refund remaining workers
# when pop goes down.
var construction_queue = []
var buildings: Array[Building] = []


func start_building(building_scene):
	emit_signal("building_selected", building_scene)

func show_building_info_panel(pos: Vector2, building_data: BuildingResource):
	emit_signal("show_info_panel", pos, building_data)

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


func reset_state():
	buildings = []
	construction_queue = []