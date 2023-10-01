extends Node

signal building_selected(building: PackedScene)

@export var hab_1: PackedScene
@export var hab_2: PackedScene
@export var hab_3: PackedScene
@export var farm_1: PackedScene
@export var farm_2: PackedScene
@export var farm_3: PackedScene
@export var water_1: PackedScene
@export var water_2: PackedScene
@export var water_3: PackedScene
@export var air_1: PackedScene
@export var air_2: PackedScene
@export var air_3: PackedScene


func _build_hab_1():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", hab_1)


func _build_hab_2():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", hab_2)


func _build_hab_3():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", hab_3)


func _build_farm_1():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", farm_1)


func _build_farm_2():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", farm_2)


func _build_farm_3():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", farm_3)


func _build_water_1():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", water_1)


func _build_water_2():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", water_2)


func _build_water_3():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", water_3)



func _build_air_1():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", air_1)


func _build_air_2():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", air_2)


func _build_air_3():
	# TODO - logic for checking the player has enough resources to build
	emit_signal("building_selected", air_3)


