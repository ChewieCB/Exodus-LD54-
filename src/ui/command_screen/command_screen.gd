extends Control
class_name CommandScreen

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var show_hide_command_screen_button: Button = $DeviceFrame/ShowHideCommandScreen
@onready var tab_container: TabContainer = $DeviceFrame/TabContainer

# Travel tab
@onready var desc_label: Label = $DeviceFrame/TabContainer/Travel/PathChoiceView/DescLabel
@onready var default_path_button: Button = $DeviceFrame/TabContainer/Travel/PathChoiceView/VBoxContainer/Button
@onready var intergalatic_route_button: Button = $DeviceFrame/TabContainer/Travel/PathChoiceView/VBoxContainer/Button2
@onready var asteroid_field_button: Button = $DeviceFrame/TabContainer/Travel/PathChoiceView/VBoxContainer/Button3
@onready var void_field_button: Button = $DeviceFrame/TabContainer/Travel/PathChoiceView/VBoxContainer/Button4
@onready var path_choice_view = $DeviceFrame/TabContainer/Travel/PathChoiceView
@onready var change_path_button: Button = $DeviceFrame/TabContainer/Travel/ChangePathButton


# Officer tab
@onready var officer_container = $DeviceFrame/TabContainer/Officers/OfficerListMC/ScrollContainer/MarginContainer/VBoxContainer
@onready var officer_desc_label = $DeviceFrame/TabContainer/Officers/OfficerDescMC/MarginContainer/OfficerDescLabel
@onready var officer_portrait = $DeviceFrame/TabContainer/Officers/OfficerPortrait

@onready var research_tab: ResearchTab = $DeviceFrame/TabContainer/Research
@onready var crewmate_tab: CrewmateTab = $DeviceFrame/TabContainer/Crewmates
@onready var status_tab: StatusTab = $DeviceFrame/TabContainer/Status

var trave_screen_open = false
var chose_path_screen_open = false
var path_length

var is_mouse_over_starmap: bool = false


const WAKEUP_CITIZEN_WATER_COST = 15


func _ready() -> void:
	reset_color_all_buttons()
	default_path_button.self_modulate = Color.GREEN
	EventManager.chosen_path = EventManager.TRAVEL_PATH_TYPE.DEFAULT_PATH
	desc_label.text = "Default path\nYou have equal chance to meet all type of events."

	TickManager.tick.connect(_update_path_follow)
	update_officer_list()


func _input(event: InputEvent):
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		if is_mouse_over_starmap or \
		# Exception for panning so we can trigger the pan return if the mouse 
		# moves out of the viewport when panning
		(event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_MIDDLE):
			$DeviceFrame/TabContainer/Travel/MarginContainer/SubViewport.push_input(event, false)

func update_officer_list():
	for child in officer_container.get_children():
		var officer_label = child as OfficerButton
		if officer_label.officer in ResourceManager.current_officers:
			officer_label.visible = true
		else:
			officer_label.visible = false

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

func _on_show_hide_command_screen_toggled(button_pressed:bool) -> void:
	update_officer_list()
	officer_desc_label.visible = false
	officer_portrait.visible = false
	research_tab.reset_stuff_on_tab()
	crewmate_tab.reset_stuff_on_tab()
	status_tab.reset_stuff_on_tab()
	if button_pressed:
		show_hide_command_screen_button.text = "Hide command screen"
		animation_player.play("show")
		trave_screen_open = true
		show_hide_command_screen_button.button_pressed = button_pressed
		$DeviceFrame/TabContainer/Travel/MarginContainer.grab_focus()

	else:
		show_hide_command_screen_button.text = "Show command screen"
		animation_player.play("hide")
		trave_screen_open = false
		show_hide_command_screen_button.button_pressed = button_pressed
		$DeviceFrame/TabContainer/Travel/MarginContainer.release_focus()

func _on_tab_container_tab_changed(tab:int) -> void:
	SoundManager.play_button_click_sfx()
	if tab_container.get_child(tab).name == research_tab.name:
		research_tab.reset_stuff_on_tab()
	if tab_container.get_child(tab).name == crewmate_tab.name:
		crewmate_tab.reset_stuff_on_tab()
	if tab_container.get_child(tab).name == status_tab.name:
		status_tab.reset_stuff_on_tab()

func hide_screen():
	if trave_screen_open:
		_on_show_hide_command_screen_toggled(false)

func show_screen():
	if not trave_screen_open:
		_on_show_hide_command_screen_toggled(true)


func _on_tab_container_tab_changed(tab:int) -> void:
	SoundManager.play_button_click_sfx()
	wakeup_warning_label.visible = false


func _on_starmap_area_mouse_entered():
	is_mouse_over_starmap = true


func _on_starmap_area_mouse_exited():
	is_mouse_over_starmap = false

