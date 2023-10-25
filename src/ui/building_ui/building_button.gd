@tool
extends MarginContainer

@export var building_object: PackedScene

@onready var name_label = $CenterContainer/HBoxContainer/VBoxContainer/MarginContainer/NameCostContainer/NameContainer/BuildingName
@onready var worker_cost_label = $%RequirementsContainer/WorkersContainer/HBoxContainer/WorkerCost
@onready var metal_cost_label = $%RequirementsContainer/MetalContainer/HBoxContainer/MetalCost
@onready var time_cost_label = $%RequirementsContainer/TimeContainer/HBoxContainer/BuildingTime
@onready var icon = $CenterContainer/HBoxContainer/MarginContainer2/BuildingIcon
@onready var production_label = $CenterContainer/HBoxContainer/VBoxContainer/MarginContainer3/HBoxContainer/BuildingProd
@onready var production_icon = $CenterContainer/HBoxContainer/VBoxContainer/MarginContainer3/HBoxContainer/TextureRect
@onready var button = $CenterContainer/HBoxContainer/MarginContainer2/Button
@onready var production_label_2 = $CenterContainer/HBoxContainer/VBoxContainer/MarginContainer3/HBoxContainer/BuildingProd2

var building_cost

func _ready():
	if building_object == null:
		return

	var building = building_object.instantiate()
	name_label.text = str(building.data.name)
	worker_cost_label.text = str(building.data.people_cost)
	metal_cost_label.text = str(building.data.metal_cost)
	time_cost_label.text = str(building.data.construction_time)
	icon.texture = building.data.sprite

	if not Engine.is_editor_hint():
		ResourceManager.workers_changed.connect(_update_status)

	var production
	var prod_type_string
	var prod_type_icon
	match building.data.type:
		Building.TYPES.HabBuilding:
			production = building.data.housing_prod
			prod_type_string = "housing"
			prod_type_icon = load("res://assets/ui/icons/16/Home.png")
			production_label_2.text = ""
		Building.TYPES.FoodBuilding:
			production = building.data.food_prod
			prod_type_string = "food"
			prod_type_icon = load("res://assets/ui/icons/food_icon.png")
		Building.TYPES.WaterBuilding:
			production = building.data.water_prod
			prod_type_string = "water"
			prod_type_icon = load("res://assets/ui/icons/water_icon.png")
		Building.TYPES.AirBuilding:
			production = building.data.air_prod
			prod_type_string = "air"
			prod_type_icon = load("res://assets/ui/icons/air_icon.png")
		Building.TYPES.MiningBuilding:
			production = building.data.metal_prod
			prod_type_string = "metal"
			prod_type_icon = load("res://assets/ui/icons/metal_icon.png")
	production_label.text = "+{0}".format([production])
	production_icon.texture = prod_type_icon


func _update_status(available_workers):
	# FIXME - this doesn't disable buttons that are too expensive
	if building_cost:
		if available_workers < building_cost:
			button.disabled = true
			self.modulate = Color(0.7, 0.7, 0.7)
	else:
		button.disabled = false
		self.modulate = Color(1, 1, 1)



func _on_button_pressed():
	SoundManager.play_button_click_sfx()
	BuildingManager.start_building(building_object)
	button.release_focus()

