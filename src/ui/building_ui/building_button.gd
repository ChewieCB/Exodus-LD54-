@tool
extends CenterContainer

@export var building_object: PackedScene

@onready var name_label = $VBoxContainer/BuildingName
@onready var icon = $VBoxContainer/BuildingIcon
@onready var production_label = $VBoxContainer/BuildingProd
@onready var button = $Button

var building_cost


func _ready():
	var building = building_object.instantiate()
	name_label.text = "{0} ({1})".format([building.data.name, building.data.people_cost])
	icon.texture = building.data.sprite
	
	ResourceManager.workers_changed.connect(_update_status)
	
	var production
	var prod_type_string
	match building.data.type:
		Building.TYPES.HabBuilding:
			production = building.data.housing_prod
			prod_type_string = "housing"
		Building.TYPES.FoodBuilding:
			production = building.data.food_prod
			prod_type_string = "food"
		Building.TYPES.WaterBuilding:
			production = building.data.water_prod
			prod_type_string = "water"
		Building.TYPES.AirBuilding:
			production = building.data.air_prod
			prod_type_string = "air"
	
	if building.data.type == Building.TYPES.HabBuilding:
		production_label.text = "+{0} {1}".format([production, prod_type_string])
	else:
		production_label.text = "+{0} {1} per tick".format([production, prod_type_string])


func _update_status(available_workers):
	if building_cost:
		if available_workers < building_cost:
			button.disabled = true
			self.modulate = Color(0.7, 0.7, 0.7)
	else:
		button.disabled = false
		self.modulate = Color(1, 1, 1)
		


func _on_button_pressed():
	BuildingManager._build(building_object)
		
