extends Node2D
class_name BuildingInfoPanel

@onready var title_label: Label = $PanelContainer/MarginContainer/Info/VBoxContainer/TitleLabel
@onready var desc_label: Label = $PanelContainer/MarginContainer/Info/VBoxContainer/DescLabel
@onready var stat_label: Label = $PanelContainer/MarginContainer/Info/VBoxContainer/StatLabel
@onready var grid_container = $PanelContainer/MarginContainer/Info/VBoxContainer/GridContainer
@onready var main_panel = $PanelContainer/MarginContainer/Info
@onready var panel_container = $PanelContainer

@onready var warehouse_spec_button: Button = $PanelContainer/MarginContainer/Info/VBoxContainer/GridContainer/WarehouseSpecializeButton
@onready var warehouse_spec_menu = $PanelContainer/MarginContainer/WarehouseSpec

@onready var sector_unlock_button: Button = $PanelContainer/MarginContainer/Info/VBoxContainer/GridContainer/SectorUnlockButton

var current_building: Building
var is_showing = false

func _ready() -> void:
	BuildingManager.show_info_panel.connect(show_panel)
	BuildingManager.hide_info_panel.connect(hide_panel)

func _input(event):
	if event.is_action_pressed("left_click"):
		# Check if the mouse click is outside the GUI
		if not Rect2(panel_container.position, panel_container.get_size()).has_point(get_local_mouse_position()):
			if is_showing:
				hide_panel()


func show_panel(pos: Vector2, building: Building):
	if is_showing:
		return
	match building.data.type:
		EnumAutoload.BuildingType.SECTOR:
			show_sector_panel(pos, building)
		_:
			show_info_panel(pos, building)

func show_info_panel(pos: Vector2, building: Building):
	main_panel.visible = true
	warehouse_spec_menu.visible = false
	is_showing = true
	global_position = get_global_mouse_position()
	title_label.text = building.get_context_menu_name()
	desc_label.text = building.get_context_menu_description()
	stat_label.text = building.get_context_menu_stat()
	visible = true

	for child in grid_container.get_children():
		child.visible = false
	if building.data.type == EnumAutoload.BuildingType.STORAGE:
		var warehouse = building as WarehouseBuilding
		if warehouse.check_condition_for_specialize():
			warehouse_spec_button.visible = true
			warehouse_spec_menu.selected_warehouse = warehouse


func show_sector_panel(pos: Vector2, building: Building):
	if is_showing:
		return
	
	main_panel.visible = true
	warehouse_spec_menu.visible = false
	if not building.is_deconstructing:
		sector_unlock_button.visible = true
	is_showing = true
	global_position = get_global_mouse_position()
	title_label.text = building.get_context_menu_name()
	desc_label.text = building.get_context_menu_description()
	stat_label.text = building.get_context_menu_stat()
	visible = true
	
	current_building = building


func hide_panel():
	is_showing = false
	visible = false


func _on_close_button_pressed() -> void:
	hide_panel()


func _on_warehouse_specialize_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	main_panel.visible = false
	warehouse_spec_menu.visible = true


func _on_sector_unlock_button_pressed():
	SoundManager.play_button_click_sfx()
	current_building.set_building_remove()
	hide_panel()
