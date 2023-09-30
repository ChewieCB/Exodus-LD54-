extends Node

signal building_selected(building: PackedScene)

@export var hab_1: PackedScene
@export var hab_2: PackedScene
@export var farm_2: PackedScene
@export var water_2: PackedScene


func _build_hab_1():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", hab_1)


func _build_hab_2():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", hab_2)


func _build_farm_2():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", farm_2)


func _build_water_2():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", water_2)


