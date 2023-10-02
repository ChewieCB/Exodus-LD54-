@tool
extends CenterContainer

@export var building_object: PackedScene

@onready var name_label = $VBoxContainer/BuildingName
@onready var icon = $VBoxContainer/BuildingIcon
@onready var production_label = $VBoxContainer/HBoxContainer/BuildingProd
@onready var production_icon = $VBoxContainer/HBoxContainer/TextureRect
@onready var button = $Button

var building_cost


func _ready():
	var building = building_object.instantiate()
	name_label.text = "{0} ({1})".format([building.data.name, building.data.people_cost])
	icon.texture = building.data.sprite
	
	ResourceManager.workers_changed.connect(_update_status)
	
	var production
	var prod_type_string
	var prod_type_icon
	match building.data.type:
		Building.TYPES.HabBuilding:
			production = building.data.housing_prod
			prod_type_string = "housing"
			prod_type_icon = load("res://assets/ui/icons/16/Home.png")
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
	BuildingManager._build(building_object)
		
