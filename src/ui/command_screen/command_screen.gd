extends Control
class_name CommandScreen

@onready var desc_label: Label = $DeviceFrame/TabContainer/Travel/PathChoiceView/DescLabel
@onready var default_path_button: Button = $DeviceFrame/TabContainer/Travel/PathChoiceView/VBoxContainer/Button
@onready var intergalatic_route_button: Button = $DeviceFrame/TabContainer/Travel/PathChoiceView/VBoxContainer/Button2
@onready var asteroid_field_button: Button = $DeviceFrame/TabContainer/Travel/PathChoiceView/VBoxContainer/Button3
@onready var void_field_button: Button = $DeviceFrame/TabContainer/Travel/PathChoiceView/VBoxContainer/Button4
@onready var path_choice_view = $DeviceFrame/TabContainer/Travel/PathChoiceView
@onready var change_path_button: Button = $DeviceFrame/TabContainer/Travel/ChangePathButton
@onready var path_follow: PathFollow2D = $DeviceFrame/TabContainer/Travel/ProgressView/Path2D/PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var show_hide_command_screen_button: Button = $DeviceFrame/ShowHideCommandScreen

# Cryostasis Citizen tab
@onready var wakeup_warning_label: Label = get_node("DeviceFrame/TabContainer/Cryostasis Citizen/WarningLabel")
@onready var count_wakeup_label: Label = get_node("DeviceFrame/TabContainer/Cryostasis Citizen/CountLabel")

# Ship tab
@onready var ship_status_label: Label = $DeviceFrame/TabContainer/Ship/ShipStatusLabel
@onready var ship_upgrade_warning_label: Label = $DeviceFrame/TabContainer/Ship/WarningLabel
@onready var ship_hull_upgrade_button: Button = $DeviceFrame/TabContainer/Ship/UpgradeHullButton

# Officer tab
@onready var officer_container = $DeviceFrame/TabContainer/Officers/VBoxContainer

var trave_screen_open = false
var chose_path_screen_open = false
var path_length

const WAKEUP_CITIZEN_WATER_COST = 15
const SHIP_HULL_METAL_COST_PER_LV = 10

func _ready() -> void:
	reset_color_all_buttons()
	default_path_button.self_modulate = Color.GREEN
	EventManager.chosen_path = EventManager.TRAVEL_PATH_TYPE.DEFAULT_PATH
	desc_label.text = "Default path\nYou have equal chance to meet all type of events."
	TickManager.tick.connect(_update_path_follow)
	update_officer_list()

func _update_path_follow():
	var path_progress = float(EventManager.tick_passed_total) / EventManager.tick_to_victory
	path_progress = clampf(path_progress, 0, 1)
	path_follow.progress_ratio = path_progress

func update_officer_list():
	for child in officer_container.get_children():
		var officer_label = child as OfficerLabel
		if officer_label.officer in ResourceManager.current_officers:
			officer_label.visible = true
		else:
			officer_label = false


func update_ship_status_screen():
	var upgrade_hull_metal_cost = EventManager.ship_hull_level * SHIP_HULL_METAL_COST_PER_LV
	ship_hull_upgrade_button.text = "Improve ship hull\n({cost} Metal)".format({"cost": upgrade_hull_metal_cost})
	ship_status_label.text = "Ship hull Lv. {ship_hull_lv}\nSpeed: ~{ship_speed} LY / day".format(
		{"ship_hull_lv": EventManager.ship_hull_level, "ship_speed": 1})

func _on_default_path_pressed() -> void:
	SoundManager.play_button_click_sfx()
	if chose_path_screen_open:
		reset_color_all_buttons()
		default_path_button.self_modulate = Color.GREEN
		EventManager.chosen_path = EventManager.TRAVEL_PATH_TYPE.DEFAULT_PATH
		desc_label.text = "Default path\nYou have equal chance to meet all type of events."


func _on_intergalatic_route_pressed() -> void:
	SoundManager.play_button_click_sfx()
	if chose_path_screen_open:
		reset_color_all_buttons()
		intergalatic_route_button.self_modulate = Color.GREEN
		EventManager.chosen_path = EventManager.TRAVEL_PATH_TYPE.INTERGALATIC_ROUTE
		desc_label.text = "Intergalatic route\nYou are more likely to meet other travellers and refugees."


func _on_asteroid_field_pressed() -> void:
	SoundManager.play_button_click_sfx()
	if chose_path_screen_open:
		reset_color_all_buttons()
		asteroid_field_button.self_modulate = Color.GREEN
		EventManager.chosen_path = EventManager.TRAVEL_PATH_TYPE.ASTEROID_FIELD
		desc_label.text = "Asteroid field\nYou are more likely to get asteroid and planet related events."


func _on_void_field_pressed() -> void:
	SoundManager.play_button_click_sfx()
	if chose_path_screen_open:
		reset_color_all_buttons()
		void_field_button.self_modulate = Color.GREEN
		EventManager.chosen_path = EventManager.TRAVEL_PATH_TYPE.VOID_FIELD
		desc_label.text = "Void field\nThere are rarely anything happened out there. But if you encounter something, you gonna have a bad time...."


func reset_color_all_buttons():
	default_path_button.self_modulate = Color.WHITE
	intergalatic_route_button.self_modulate = Color.WHITE
	asteroid_field_button.self_modulate = Color.WHITE
	void_field_button.self_modulate = Color.WHITE


func _on_change_path_button_toggled(button_pressed:bool) -> void:
	SoundManager.play_button_click_sfx()
	var tween = get_tree().create_tween()
	if button_pressed:
		change_path_button.text = "Close"
		tween.parallel().tween_property(path_choice_view, "modulate:a", 1, 0.5).set_trans(Tween.TRANS_LINEAR)
		chose_path_screen_open = true
	else:
		change_path_button.text = "Change path"
		tween.parallel().tween_property(path_choice_view, "modulate:a", 0, 0.5).set_trans(Tween.TRANS_LINEAR)
		chose_path_screen_open = false


func _on_show_hide_travel_screen_toggled(button_pressed:bool) -> void:
	wakeup_warning_label.visible = false
	if button_pressed:
		show_hide_command_screen_button.text = "Hide command screen"
		animation_player.play("show")
		trave_screen_open = true
		show_hide_command_screen_button.button_pressed = button_pressed

	else:
		show_hide_command_screen_button.text = "Show command screen"
		animation_player.play("hide")
		trave_screen_open = false
		show_hide_command_screen_button.button_pressed = button_pressed


func _on_wake_up_citizen():
	SoundManager.play_button_click_sfx()
	var result = ResourceManager.wake_up_citizen(WAKEUP_CITIZEN_WATER_COST)
	match result:
		"success":
			wakeup_warning_label.visible = false
			EventManager.n_woke_up_citizen += 1
			count_wakeup_label.text = "Woke up {n_citizen} citizen".format({"n_citizen": EventManager.n_woke_up_citizen})
		"fail_water":
			wakeup_warning_label.text = "Warning: Not enough water"
			wakeup_warning_label.visible = true
		"fail_housing":
			wakeup_warning_label.text = "Warning: Not enough housing"
			wakeup_warning_label.visible = true



func hide_screen():
	if trave_screen_open:
		_on_show_hide_travel_screen_toggled(false)


func show_screen():
	if not trave_screen_open:
		_on_show_hide_travel_screen_toggled(true)


func _on_tab_container_tab_changed(tab:int) -> void:
	SoundManager.play_button_click_sfx()
	wakeup_warning_label.visible = false


func _on_upgrade_hull_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	var upgrade_hull_metal_cost = EventManager.ship_hull_level * SHIP_HULL_METAL_COST_PER_LV
	if ResourceManager.metal_amount >= upgrade_hull_metal_cost:
		ResourceManager.metal_amount -= upgrade_hull_metal_cost
		ship_upgrade_warning_label.visible = false
		EventManager.ship_hull_level += 1
		update_ship_status_screen()
	else:
		ship_upgrade_warning_label.text = "Warning: Not enough resource"
		ship_upgrade_warning_label.visible = true
