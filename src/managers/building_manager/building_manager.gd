extends Node

signal building_selected(building: PackedScene)
signal not_enough_workers


func _build(building_scene):
	emit_signal("building_selected", building_scene)

