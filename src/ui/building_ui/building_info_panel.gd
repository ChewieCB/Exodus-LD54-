extends Node2D
class_name BuildingInfoPanel

@onready var title_label: Label = $Margin/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var desc_label: Label = $Margin/PanelContainer/MarginContainer/VBoxContainer/DescLabel
@onready var stat_label: Label = $Margin/PanelContainer/MarginContainer/VBoxContainer/StatLabel

const Utils = preload("res://src/common/exodus_utils.gd")

func _ready() -> void:
    BuildingManager.show_info_panel.connect(show_info_panel)
    BuildingManager.hide_info_panel.connect(hide_info_panel)

func show_info_panel(pos: Vector2, building_data: BuildingResource):
    global_position = get_global_mouse_position()
    title_label.text = building_data.name
    match building_data.type:
        EnumAutoload.BuildingType.HAB:
            desc_label.text = "Can house {n_house} crew members.".format({"n_house": building_data.housing_prod})
        EnumAutoload.BuildingType.FOOD:
            desc_label.text = "Can produce {n_food} units of Food per day.".format({"n_food": building_data.food_prod})
        EnumAutoload.BuildingType.WATER:
            desc_label.text = "Can produce {n_water} units of Water per day.".format({"n_water": building_data.water_prod})
        EnumAutoload.BuildingType.AIR:
            desc_label.text = "Can produce {n_air} units of Oxygen per day.".format({"n_air": building_data.air_prod})
        EnumAutoload.BuildingType.METAL:
            desc_label.text = "Can produce {n_metal} units of Metal per day.".format({"n_metal": building_data.metal_prod})
        EnumAutoload.BuildingType.CRYO_POD:
            desc_label.text = "Can be deconstructed to wake up {n_pop} crew member(s).".format({"n_pop": building_data.refund_population})
        EnumAutoload.BuildingType.STORAGE:
            desc_label.text = "Increased max storage capacity by {n_storage} units.".format({"n_storage": Utils.calculate_storage_with_upgrade(building_data.storage_prod)})
    stat_label.text = "Deconstruct time: {n_des_day} day(s)".format({"n_des_day": Utils.calculate_build_time_with_upgrade(building_data.destruction_time)})
    stat_label.text += "\nWorkers required: {n_des_pop} crewmate(s)".format({"n_des_pop": building_data.people_cost})
    visible = true

func hide_info_panel():
    visible = false
