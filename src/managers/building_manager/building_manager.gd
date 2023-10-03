extends Node

signal building_selected(building: PackedScene)
signal not_enough_workers

# Array to store each building under construction in order from most recent
# to least recent, used so we can cancel construction and refund remaining workers
# when pop goes down.
var construction_queue = []


func _build(building_scene):
	emit_signal("building_selected", building_scene)

