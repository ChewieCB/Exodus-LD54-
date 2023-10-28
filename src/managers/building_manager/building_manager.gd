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


func start_building(building_scene):
	emit_signal("building_selected", building_scene)

func show_building_info_panel(pos: Vector2, building_data: BuildingResource):
	emit_signal("show_info_panel", pos, building_data)

func hide_building_info_panel():
	emit_signal("hide_info_panel")