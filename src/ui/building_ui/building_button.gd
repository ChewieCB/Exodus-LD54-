@tool
extends MarginContainer

@export var building_object: PackedScene
@export var require_upgrade_id: EnumAutoload.UpgradeId = EnumAutoload.UpgradeId.NONE

@onready var name_label = $CenterContainer/HBoxContainer/VBoxContainer/MarginContainer/NameCostContainer/NameContainer/BuildingName
@onready var worker_cost_label = $%RequirementsContainer/WorkersContainer/HBoxContainer/WorkerCost
@onready var metal_cost_label = $%RequirementsContainer/MetalContainer/HBoxContainer/MetalCost
@onready var time_cost_label = $%RequirementsContainer/TimeContainer/HBoxContainer/BuildingTime
@onready var icon = $CenterContainer/HBoxContainer/MarginContainer2/BuildingIcon
@onready var production_label = $CenterContainer/HBoxContainer/VBoxContainer/MarginContainer3/HBoxContainer/BuildingProd
@onready var production_icon = $CenterContainer/HBoxContainer/VBoxContainer/MarginContainer3/HBoxContainer/TextureRect
@onready var button = $CenterContainer/HBoxContainer/MarginContainer2/Button
@onready var production_label_2 = $CenterContainer/HBoxContainer/VBoxContainer/MarginContainer3/HBoxContainer/BuildingProd2

var building: Building

const Utils = preload("res://src/common/exodus_utils.gd")

func _ready():
	if building_object == null:
		return

	building = building_object.instantiate()
	name_label.text = str(building.data.name)
	worker_cost_label.text = str(building.data.people_cost)
	metal_cost_label.text = str(building.data.metal_cost)
	time_cost_label.text = str(building.data.construction_time)
	icon.texture = building.data.sprite

	if not Engine.is_editor_hint():
		ResourceManager.workers_changed.connect(_update_status)
		ResourceManager.upgrade_acquired.connect(_update_info_after_upgrade)
		_update_info_after_upgrade()
		set_tooltip()

	var production
	var prod_type_string
	var prod_type_icon
	match building.data.type:
		EnumAutoload.BuildingType.HAB:
			production = building.data.housing_prod
			prod_type_string = "housing"
			prod_type_icon = load("res://assets/ui/icons/16/Home.png")
			production_label_2.text = ""
		EnumAutoload.BuildingType.FOOD:
			production = building.data.food_prod
			prod_type_string = "food"
			prod_type_icon = load("res://assets/ui/icons/food_icon.png")
		EnumAutoload.BuildingType.WATER:
			production = building.data.water_prod
			prod_type_string = "water"
			prod_type_icon = load("res://assets/ui/icons/water_icon.png")
		EnumAutoload.BuildingType.AIR:
			production = building.data.air_prod
			prod_type_string = "air"
			prod_type_icon = load("res://assets/ui/icons/air_icon.png")
		EnumAutoload.BuildingType.METAL:
			production = building.data.metal_prod
			prod_type_string = "metal"
			prod_type_icon = load("res://assets/ui/icons/metal_icon.png")
		EnumAutoload.BuildingType.STORAGE:
			production = building.data.storage_prod
			prod_type_string = "storage"
			prod_type_icon = load("res://assets/ui/icons/storage_icon.png")
	production_label.text = "+{0}".format([production])
	production_icon.texture = prod_type_icon

func _update_status(available_workers):
	if available_workers < building.data.people_cost:
		button.disabled = true
		self.modulate = Color(0.7, 0.7, 0.7)
	else:
		button.disabled = false
		self.modulate = Color(1, 1, 1)

func _on_button_pressed():
	SoundManager.play_button_click_sfx()
	BuildingManager.start_building(building_object)
	button.release_focus()

func _update_info_after_upgrade():
	metal_cost_label.text = str(Utils.calculate_build_cost_with_upgrade(building.data.metal_cost))
	time_cost_label.text = str(Utils.calculate_build_time_with_upgrade(building.data.construction_time))

	if building.data.type == EnumAutoload.BuildingType.STORAGE:
		var production = Utils.calculate_storage_with_upgrade(building.data.storage_prod)
		production_label.text = "+{0}".format([production])

	if require_upgrade_id == EnumAutoload.UpgradeId.NONE:
		visible = true
		return
	
	if require_upgrade_id in ResourceManager.current_upgrades:
		visible = true
	else:
		visible = false


func set_tooltip():
	var tmp_text = ""
	match building.data.type:
		EnumAutoload.BuildingType.HAB:
			tmp_text = "Can house {n_house} crew members.".format({"n_house": building.data.housing_prod})
		EnumAutoload.BuildingType.FOOD:
			tmp_text = "Can produce {n_food} units of Food per day.".format({"n_food": building.data.food_prod})
		EnumAutoload.BuildingType.WATER:
			tmp_text = "Can produce {n_water} units of Water per day.".format({"n_water": building.data.water_prod})
		EnumAutoload.BuildingType.AIR:
			tmp_text = "Can produce {n_air} units of Oxygen per day.".format({"n_air": building.data.air_prod})
		EnumAutoload.BuildingType.METAL:
			tmp_text = "Can produce {n_metal} units of Metal per day.".format({"n_metal": building.data.metal_prod})
		EnumAutoload.BuildingType.CRYO_POD:
			tmp_text = "Can be deconstructed to wake up {n_pop} crew members.".format({"n_pop": building.data.refund_population})
		EnumAutoload.BuildingType.CRYO_POD:
			tmp_text = "Increased max storage capacity by {n_storage} units.".format({"n_storage": Utils.calculate_storage_with_upgrade(building.data.storage_prod)})
	tmp_text += "\nConstruction time: {n_day} day(s)".format({"n_day": Utils.calculate_build_time_with_upgrade(building.data.construction_time)})
	tmp_text += "\nWorkers required: {n_pop} crewmate(s)".format({"n_pop": building.data.people_cost})
	tmp_text += "\nMetal required: {n_metal} unit(s)".format({"n_metal": Utils.calculate_build_cost_with_upgrade(building.data.metal_cost)})
	get_node("CenterContainer/HBoxContainer/VBoxContainer/Tooltip").tooltip_text = tmp_text

	
