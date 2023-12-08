@tool
extends MarginContainer

@export var building_object: PackedScene
@export var require_upgrade_id: EnumAutoload.UpgradeId = EnumAutoload.UpgradeId.NONE

@onready var name_label = $CenterContainer/HBoxContainer/VBoxContainer/MarginContainer/NameCostContainer/NameContainer/BuildingName
@onready var worker_cost_label = $%RequirementsContainer/WorkersContainer/HBoxContainer/WorkerCost
@onready var time_cost_label = $%RequirementsContainer/TimeContainer/HBoxContainer/BuildingTime
@onready var building_icon = $CenterContainer/HBoxContainer/MarginContainer2/BuildingIcon
@onready var button = $CenterContainer/HBoxContainer/MarginContainer2/Button

@onready var cost_rtl: RichTextLabel = $CenterContainer/HBoxContainer/VBoxContainer/CostRTL
@onready var prod_rtl: RichTextLabel = $CenterContainer/HBoxContainer/VBoxContainer/ProdRTL

const FOOD_ICON = "res://assets/ui/icons/food_icon.png"
const WATER_ICON = "res://assets/ui/icons/water_icon.png"
const AIR_ICON = "res://assets/ui/icons/air_icon.png"
const METAL_ICON = "res://assets/ui/icons/metal_icon.png"
const HAB_ICON = "res://assets/ui/icons/16/Home.png"
const STORAGE_ICON = "res://assets/ui/icons/storage_icon.png"

var building: Building

const Utils = preload("res://src/common/exodus_utils.gd")

func _ready():
	if building_object == null:
		return

	building = building_object.instantiate()
	name_label.text = str(building.data.name)
	worker_cost_label.text = str(building.data.people_cost)
	time_cost_label.text = str(building.data.construction_time)
	building_icon.texture = building.data.sprite

	if not Engine.is_editor_hint():
		ResourceManager.workers_changed.connect(_update_status)
		ResourceManager.upgrade_acquired.connect(_update_info_after_upgrade)

	_update_info_after_upgrade()


func get_resource_string_with_icon(resource_data: ResourceData, multiplier: int = 1) -> String:
	if resource_data == null:
		return "Error"
	var tmp = ""
	if resource_data.metal > 0:
		tmp += "{0} [img]{1}[/img] ".format([resource_data.metal * multiplier, METAL_ICON])
	if resource_data.food > 0:
		tmp += "{0} [img]{1}[/img] ".format([resource_data.food * multiplier, FOOD_ICON])
	if resource_data.water > 0:
		tmp += "{0} [img]{1}[/img] ".format([resource_data.water * multiplier, WATER_ICON])
	if resource_data.air > 0:
		tmp += "{0} [img]{1}[/img] ".format([resource_data.air * multiplier, AIR_ICON])
	return tmp

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
	var cost_string = ""
	var prod_string = ""
	var non_prod_string = ""
	var cost_multiplier = 1
	var warehouse_multiplier = 1

	# Still miss a lot of cases such as production multipliers, but I will deal with
	# it when it come to that

	if not Engine.is_editor_hint():
		cost_multiplier = Utils.get_build_cost_with_upgrade_multiplier()
		warehouse_multiplier = Utils.get_storage_with_upgrade_multiplier()

	cost_string = get_resource_string_with_icon(building.data.resource_cost, cost_multiplier)
	if cost_string != "":
		cost_string = "Cost " + cost_string
	cost_rtl.text = "[center]" + cost_string + "[/center]"

	prod_string = get_resource_string_with_icon(building.data.resource_prod)
	if prod_string != "":
		prod_string = "+" + prod_string + "per day\n"

	if building.data.housing_prod > 0:
		non_prod_string += "{0} [img]{1}[/img] ".format([building.data.housing_prod, HAB_ICON])
	if building.data.storage_prod > 0:
		non_prod_string += "{0} [img]{1}[/img] ".format([building.data.storage_prod * warehouse_multiplier, STORAGE_ICON])
	if non_prod_string != "":
		non_prod_string = "+" + non_prod_string
	prod_rtl.text = "[center]" + prod_string + non_prod_string + "[/center]"

	if not Engine.is_editor_hint():
		if require_upgrade_id == EnumAutoload.UpgradeId.NONE || \
			require_upgrade_id in ResourceManager.current_upgrades:
			visible = true
		else:
			visible = false


func _on_tooltip_mouse_entered() -> void:
	BuildingManager.show_building_info_panel(global_position, building)

func _on_tooltip_mouse_exited() -> void:
	BuildingManager.hide_building_info_panel()
