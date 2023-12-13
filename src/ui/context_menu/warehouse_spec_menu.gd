extends MarginContainer

var selected_warehouse: WarehouseBuilding = null
var main_panel: BuildingInfoPanel = null

func _ready() -> void:
	main_panel = get_parent().get_parent().get_parent()

func _on_water_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	selected_warehouse.set_specialisation(EnumAutoload.ResourceType.WATER)
	main_panel.hide_info_panel()

func _on_metal_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	selected_warehouse.set_specialisation(EnumAutoload.ResourceType.METAL)
	main_panel.hide_info_panel()

func _on_oxygen_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	selected_warehouse.set_specialisation(EnumAutoload.ResourceType.AIR)
	main_panel.hide_info_panel()

func _on_food_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	selected_warehouse.set_specialisation(EnumAutoload.ResourceType.FOOD)
	main_panel.hide_info_panel()
