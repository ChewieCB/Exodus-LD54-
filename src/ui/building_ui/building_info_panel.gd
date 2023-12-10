extends Node2D
class_name BuildingInfoPanel

@onready var title_label: Label = $Margin/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var desc_label: Label = $Margin/PanelContainer/MarginContainer/VBoxContainer/DescLabel
@onready var stat_label: Label = $Margin/PanelContainer/MarginContainer/VBoxContainer/StatLabel

func _ready() -> void:
	BuildingManager.show_info_panel.connect(show_info_panel)
	BuildingManager.hide_info_panel.connect(hide_info_panel)

func show_info_panel(pos: Vector2, building: Building):
	var building_data = building.data
	global_position = get_global_mouse_position()
	title_label.text = building_data.name
	match building_data.type:
		EnumAutoload.BuildingType.HABITATION:
			desc_label.text = "Can house {n_house} crew members.".format({"n_house": building_data.housing_prod})
		EnumAutoload.BuildingType.FOOD:
			desc_label.text = "Can produce {n_food} units of Food per day.".format({"n_food": building.get_produced_resource().food})
		EnumAutoload.BuildingType.WATER:
			desc_label.text = "Can produce {n_water} units of Water per day.".format({"n_water": building.get_produced_resource().water})
		EnumAutoload.BuildingType.AIR:
			desc_label.text = "Can produce {n_air} units of Oxygen per day.".format({"n_air": building.get_produced_resource().air})
		EnumAutoload.BuildingType.METAL:
			desc_label.text = "Can produce {n_metal} units of Metal per day.".format({"n_metal": building.get_produced_resource().metal})
		EnumAutoload.BuildingType.CRYO_POD:
			desc_label.text = "Can be deconstructed to wake up {n_pop} crew member(s).".format({"n_pop": building_data.refund_population})
		EnumAutoload.BuildingType.STORAGE:
			desc_label.text = "Increased max storage capacity by {n_storage} units.".format({"n_storage": ResourceManager.calculate_storage_with_upgrade(building_data.storage_prod)})
	stat_label.text = "Construct time: {0} day(s), {1} crewmate(s)".format([ResourceManager.calculate_build_time_with_upgrade(building_data.construction_time), building_data.people_cost])
	stat_label.text += "\nDeconstruct time: {0} day(s), {1} crewmate(s)".format([ResourceManager.calculate_build_time_with_upgrade(building_data.destruction_time), building_data.people_cost])
	if building.bonus_multiplier > 1:
		stat_label.text += "\nCurrent bonus multiplier: {mul}".format({"mul": building.bonus_multiplier})
	visible = true

func hide_info_panel():
	visible = false
