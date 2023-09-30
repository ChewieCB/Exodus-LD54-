extends Node2D

@export var building_a: PackedScene
@export var building_b: PackedScene
@export var building_c: PackedScene
@onready var grid_placement: GridPlacement = $GridPlacement

func choose_building_a():
	grid_placement.building = building_a
	grid_placement.stop_building_preview()
	grid_placement.get_new_building()

func choose_building_b():
	grid_placement.building = building_b
	grid_placement.stop_building_preview()
	grid_placement.get_new_building()

func choose_building_c():
	grid_placement.building = building_c
	grid_placement.stop_building_preview()
	grid_placement.get_new_building()
