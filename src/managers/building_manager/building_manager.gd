extends Node

signal building_selected(building: PackedScene)


func _build(building_scene):
	emit_signal("building_selected", building_scene)

