extends MarginContainer

var selected_warehouse: WarehouseBuilding = null
var main_panel: BuildingInfoPanel = null

func _ready() -> void:
	main_panel = get_parent().get_parent().get_parent()

func _on_water_button_pressed() -> void:
	_on_resource_button_pressed(EnumAutoload.ResourceType.WATER)

func _on_metal_button_pressed() -> void:
	_on_resource_button_pressed(EnumAutoload.ResourceType.METAL)

func _on_oxygen_button_pressed() -> void:
	_on_resource_button_pressed(EnumAutoload.ResourceType.AIR)

func _on_food_button_pressed() -> void:
	_on_resource_button_pressed(EnumAutoload.ResourceType.FOOD)

func _on_resource_button_pressed(resource_type: EnumAutoload.ResourceType):
	SoundManager.play_button_click_sfx()
	selected_warehouse.set_specialisation(resource_type)
	main_panel.hide_info_panel()
