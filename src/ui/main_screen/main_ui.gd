extends Control
class_name MainUI

@export var ship_sprite: Sprite2D
@export var ship_build_frame: Sprite2D
@export var command_screen: CommandScreen
@export var ship_grid: Node2D
@export var camera: Camera2D
@export var mid_view_marker: Marker2D
@export var far_view_marker: Marker2D
@export var space_background: Sprite2D
@export var event_image_holder: Node2D

#@onready var build_show_toggle: MarginContainer = $LowerBar/MarginContainer/HBoxContainer/BuildShowToggle
@onready var build_menu: MarginContainer = $BuildMenu
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var objective_label: Label = $ObjectiveLabel
@onready var time_control_ui = $LowerBar/MarginContainer/HBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/TimeControlUI
@onready var debug_event_dropdown = $DebugEventsMenu/MarginContainer/PanelContainer/VBoxContainer/OptionButton
@onready var chat_crew_button: Button = $ChatCrewButton

@onready var DEBUG_build_tag: Label = $LowerBar/MarginContainer/HBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/DEBUG_BuildTag/Label

var build_menu_open = false
var event_image: Sprite2D
var event_planet_holder: Node2D

var tween: Tween

const BUILD_MENU_CAMERA_ZOOM = Vector2(0.6, 0.6)
const SHIP_CAMERA_ZOOM = Vector2(0.4, 0.4)
const EVENT_CAMERA_ZOOM = Vector2(0.15, 0.15)


func _ready() -> void:
	EventManager.start_event.connect(_on_start_event)
	EventManager.dialogic_signal.connect(_on_dialogic_signal)
	EventManager.request_change_objective_label.connect(change_objective_label)
	EventManager.request_change_event_image.connect(change_event_image)
	if event_image_holder:
		event_image = event_image_holder.get_node("EventImage")
		event_planet_holder = event_image_holder.get_node("EventPlanetHolder")

	get_parent().get_parent().connect("ship_selected", show_build_view)
	get_parent().get_parent().connect("ship_deselected", hide_build_view)

	command_screen.main_ui = self

	# Read in the build version tag from the config and update the label
	DEBUG_build_tag.text = EnumAutoload.BUILD_VERSION


func _unhandled_input(event: InputEvent) -> void:
	if build_menu_open:
		# Zooming with mouse wheel
		var zoom = camera.zoom
		if event.is_action_pressed("zoom_in"):
			zoom += Vector2(0.05, 0.05)
		elif event.is_action_pressed("zoom_out"):
			zoom -= Vector2(0.05, 0.05)
		camera.zoom = clamp(zoom, Vector2(0.2, 0.2), Vector2(2, 2))

		if event is InputEventMouseMotion and Input.is_action_pressed("drag_camera"):
			var drag_modifier = remap(camera.zoom[0], 0.2, 2, 1, 0.5)
			camera.global_position -= event.relative * Vector2(drag_modifier, drag_modifier)


# FIXME - DEPRECATED
func _on_build_button_pressed():
	pass


func show_build_view():
	if build_menu_open:
		return
	SoundManager.play_button_click_sfx()
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	anim_player.play("show_build_menu")
	build_menu_open = true
	command_screen.hide_screen()
	if ship_grid != null:
		ship_grid.visible = true
		ship_build_frame.visible = true
		tween.parallel().tween_property(camera, "global_position", ship_sprite.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
		tween.parallel().tween_property(camera, "zoom", BUILD_MENU_CAMERA_ZOOM, 0.5).set_trans(Tween.TRANS_LINEAR)


func hide_build_view():
	if not build_menu_open:
		return
	SoundManager.play_button_click_sfx()
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	anim_player.play("hide_build_menu")
	build_menu_open = false
	if ship_grid != null:
		ship_grid.visible = false
		ship_build_frame.visible = false
		tween.parallel().tween_property(camera, "zoom", SHIP_CAMERA_ZOOM, 0.5).set_trans(Tween.TRANS_LINEAR)
		tween.parallel().tween_property(camera, "global_position", mid_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)


func _on_play_dialog_pressed():
	SoundManager.play_button_click_sfx()
	TickManager.stop_ticks()
	if build_menu_open:
		anim_player.play("hide_build_menu")
		build_menu_open = false
	ship_grid.visible = false
#	build_show_toggle.visible = false
	build_menu.visible = false
	EventManager.get_next_event()


func _on_chat_crew_pressed():
	SoundManager.play_button_click_sfx()
	TickManager.stop_ticks()
	if build_menu_open:
		anim_player.play("hide_build_menu")
		build_menu_open = false
	ship_grid.visible = false
#	build_show_toggle.visible = false
	build_menu.visible = false
	EventManager.play_space_fact_event()


func _open_build_menu():
	if build_menu_open:
		return
#	build_show_toggle.visible = true
	build_menu.visible = true
	anim_player.play("show_build_menu")
	build_menu_open = true
	ship_grid.visible = true
	ship_build_frame.visible = true
	tween = get_tree().create_tween()
	tween.parallel().tween_property(camera, "global_position", ship_sprite.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(camera, "zoom", BUILD_MENU_CAMERA_ZOOM, 0.5).set_trans(Tween.TRANS_LINEAR)
	command_screen.hide_screen()


func _on_start_event(event: ExodusEvent):
	TickManager.stop_ticks()
	tween = get_tree().create_tween()
	EventManager.is_in_event = true
#	command_screen.hide_screen()

	match event.active_screen:
		ExodusEvent.ACTIVE_SCREEN.BUILD:
			tween.parallel().tween_property(camera, "zoom", Vector2(0.5, 0.5), 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(camera, "global_position", ship_sprite.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
			ship_grid.visible = true
			ship_build_frame.visible = true
			build_menu.visible = true
		ExodusEvent.ACTIVE_SCREEN.NAV:
			if build_menu_open:
				anim_player.play("hide_build_menu")
				build_menu_open = false
			tween.parallel().tween_property(camera, "zoom", SHIP_CAMERA_ZOOM, 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(camera, "global_position", mid_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
			ship_grid.visible = false
			ship_build_frame.visible = false
			build_menu.visible = false
		ExodusEvent.ACTIVE_SCREEN.EVENT:
			if build_menu_open:
				anim_player.play("hide_build_menu")
				build_menu_open = false
			tween.parallel().tween_property(camera, "zoom", EVENT_CAMERA_ZOOM, 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(camera, "global_position", far_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(event_image_holder, "modulate:a", 1, 1.0).set_trans(Tween.TRANS_LINEAR)
			ship_grid.visible = false
			ship_build_frame.visible = false
			build_menu.visible = false

	chat_crew_button.disabled = true
	time_control_ui.disable_buttons()


func _on_dialogic_signal(arg: String):
	match arg:
		"change_to_build_screen":
			tween = get_tree().create_tween()
			if event_image_holder:
				tween.tween_property(event_image_holder, "modulate:a", 0, 1.0).set_trans(Tween.TRANS_LINEAR)
			ship_grid.visible = true
			ship_build_frame.visible = true
#			build_show_toggle.visible = true
			build_menu.visible = true
		"change_to_nav_screen":
			tween = get_tree().create_tween()
			if event_image_holder:
				tween.tween_property(event_image_holder, "modulate:a", 0, 1.0).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(camera, "zoom", SHIP_CAMERA_ZOOM, 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(camera, "global_position", mid_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
			ship_grid.visible = false
			ship_build_frame.visible = false
#			build_show_toggle.visible = true
			build_menu.visible = false
		"change_to_event_screen":
			tween = get_tree().create_tween()
			tween.parallel().tween_property(camera, "zoom", EVENT_CAMERA_ZOOM, 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(camera, "global_position", far_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(event_image_holder, "modulate:a", 1, 1.0).set_trans(Tween.TRANS_LINEAR)
			ship_grid.visible = false
			ship_build_frame.visible = false
			build_menu.visible = false
		"end_event":
			tween = get_tree().create_tween()
			if event_image_holder:
				tween.tween_property(event_image_holder, "modulate:a", 0, 1.0).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(camera, "zoom", SHIP_CAMERA_ZOOM, 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(camera, "global_position", mid_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(command_screen, "modulate:a", 1, 1.0).set_trans(Tween.TRANS_LINEAR)
			build_menu.visible = true
			time_control_ui.enable_buttons()
			time_control_ui._on_speed_1_button_pressed()
			chat_crew_button.disabled = false
			ResourceManager.check_if_all_crew_died()
			EventManager.stop_current_vo()
			EventManager.is_in_event = false

		# Hack to end an event with the build menu open for tutorials and such
		"end_event_build":
			tween = get_tree().create_tween()
			tween.tween_property(command_screen, "modulate:a", 1, 1.0).set_trans(Tween.TRANS_LINEAR)
			if event_image_holder:
				tween.tween_property(event_image_holder, "modulate:a", 0, 1.0).set_trans(Tween.TRANS_LINEAR)
			build_menu.visible = true
			chat_crew_button.disabled = false
			ResourceManager.check_if_all_crew_died()
			time_control_ui.enable_buttons()
			time_control_ui._on_pause_button_pressed()
			EventManager.stop_current_vo()
			EventManager.is_in_event = false

		"open_build_screen":
			_open_build_menu()


func change_event_image(_texture: Texture2D, planet_type: ExodusEvent.PlanetType):
	if _texture:
		event_image.texture = _texture
	else:
		event_image.texture = null

	for p in event_planet_holder.get_children():
		p.queue_free()

	if planet_type != ExodusEvent.PlanetType.NONE:
		var new_p = EventManager.planets[planet_type].instantiate()
		new_p.position = Vector2(0, 0)
		event_planet_holder.add_child(new_p)
		new_p.set_seed(randi_range(1, 100000))


func change_objective_label(text: String):
	objective_label.text = "Objective: " + text


func _on_debug_event_menu_button_item_selected(index):
	# Adjust for separator items
	var id = debug_event_dropdown.get_item_id(index)
	var event_name = debug_event_dropdown.get_item_text(index)
	EventManager.play_event(EventManager.event_dict[id])
	debug_event_dropdown.select(-1)
