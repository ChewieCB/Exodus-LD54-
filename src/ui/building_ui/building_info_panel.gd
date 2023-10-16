extends Node2D
class_name BuildingInfoPanel

@onready var title_label: Label = $Margin/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var desc_label: Label = $Margin/PanelContainer/MarginContainer/VBoxContainer/DescLabel
@onready var stat_label: Label = $Margin/PanelContainer/MarginContainer/VBoxContainer/StatLabel


func _ready() -> void:
    BuildingManager.show_info_panel.connect(show_info_panel)
    BuildingManager.hide_info_panel.connect(hide_info_panel)

func show_info_panel(pos: Vector2, building_data: BuildingResource):
    global_position = get_global_mouse_position()
    title_label.text = building_data.name
    match building_data.type:
        Building.TYPES.HabBuilding:
            desc_label.text = "Can house {n_house} crew member.".format({"n_house": building_data.housing_prod})
        Building.TYPES.FoodBuilding:
            desc_label.text = "Can produce {n_food} unit of Food per day.".format({"n_food": building_data.food_prod})
        Building.TYPES.WaterBuilding:
            desc_label.text = "Can produce {n_water} unit of Water per day.".format({"n_house": building_data.water_prod})
        Building.TYPES.AirBuilding:
            desc_label.text = "Can produce {n_air} unit of Oxygen per day.".format({"n_house": building_data.air_prod})
        Building.TYPES.CryoPod:
            desc_label.text = "Can be deconstructed to wake up {n_pop} crew member(s).".format({"n_pop": building_data.refund_population})

    stat_label.text = "Deconstruct time: {n_des_day} day(s)".format({"n_des_day": building_data.destruction_time})
    stat_label.text += "\nWorkers required: {n_des_pop} crewmate(s)".format({"n_des_pop": building_data.people_cost})
    visible = true

func hide_info_panel():
    visible = false
