extends Control

@export var ship_sprite: Sprite2D
@export var ship_build_frame: Sprite2D
@export var background_screen: Sprite2D
@export var ship_grid: Node2D
@export var camera: Camera2D
@export var mid_view_marker: Marker2D
@export var far_view_marker: Marker2D
@export var space_background: Sprite2D
@export var event_image: Sprite2D

@onready var build_show_toggle: MarginContainer = $BuildShowToggle
@onready var build_menu: MarginContainer = $BuildMenu
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var objective_label: Label = $ObjectiveLabel
@onready var time_control_ui = $TimeControlUI/MarginContainer

@onready var debug_event_dropdown = $DebugEventsMenu/MarginContainer/PanelContainer/VBoxContainer/OptionButton


var build_menu_open = false

var button_click_sfx = preload("res://assets/audio/sfx/ui_click_1.mp3")

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	EventManager.start_event.connect(_on_start_event)
	EventManager.request_change_objective_label.connect(change_objective_label)
	EventManager.request_change_event_image.connect(change_event_image)

	if EventManager.tutorial_progress == -1:
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(camera, "zoom", Vector2(0.4, 0.4), 0.5).set_trans(Tween.TRANS_LINEAR)
		tween.parallel().tween_property(camera, "global_position", mid_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
		tween.parallel().tween_property(background_screen, "modulate:a", 1, 1.0).set_trans(Tween.TRANS_LINEAR)

func _on_build_button_pressed():
	if anim_player.animation_finished:
		SoundManager.play_sound(button_click_sfx, "UI")
		var tween = get_tree().create_tween()
		if build_menu_open:
			anim_player.play("hide_build_menu")
			build_menu_open = false
			if ship_grid != null:
				ship_grid.visible = false
				ship_build_frame.visible = false
				tween.parallel().tween_property(camera, "zoom", Vector2(0.4, 0.4), 0.5).set_trans(Tween.TRANS_LINEAR)
				tween.parallel().tween_property(camera, "global_position", mid_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
		else:
			anim_player.play("show_build_menu")
			build_menu_open = true
			if ship_grid != null:
				ship_grid.visible = true
				ship_build_frame.visible = true
				tween.parallel().tween_property(camera, "global_position", ship_sprite.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
				tween.parallel().tween_property(camera, "zoom", Vector2(0.5, 0.5), 0.5).set_trans(Tween.TRANS_LINEAR)


func _on_play_dialog_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	TickManager.stop_ticks()
	if build_menu_open:
		anim_player.play("hide_build_menu")
		build_menu_open = false
	ship_grid.visible = false
	build_show_toggle.visible = false
	build_menu.visible = false
	EventManager.get_next_event()
#	EventManager.play_random_event()


func _on_listen_fact_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	TickManager.stop_ticks()
	if build_menu_open:
		anim_player.play("hide_build_menu")
		build_menu_open = false
	ship_grid.visible = false
	build_show_toggle.visible = false
	build_menu.visible = false
	EventManager.play_specific_event("space_fact_event")


func _on_start_event(event_name: String):
	TickManager.stop_ticks()
	var tween = get_tree().create_tween()

	if build_menu_open:
		anim_player.play("hide_build_menu")
		build_menu_open = false

	# For some events, we dont need to zoom farside
	if event_name in ["tutorial1_event", "tutorial2_event", "space_fact_event"]:
		tween.parallel().tween_property(camera, "zoom", Vector2(0.4, 0.4), 0.5).set_trans(Tween.TRANS_LINEAR)
		tween.parallel().tween_property(camera, "global_position", mid_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
	else:
		tween.parallel().tween_property(camera, "zoom", Vector2(0.15, 0.15), 0.5).set_trans(Tween.TRANS_LINEAR)
		tween.parallel().tween_property(camera, "global_position", far_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
		tween.parallel().tween_property(event_image, "modulate:a", 1, 1.0).set_trans(Tween.TRANS_LINEAR)
		tween.parallel().tween_property(background_screen, "modulate:a", 0, 1.0).set_trans(Tween.TRANS_LINEAR)
	ship_grid.visible = false
	ship_build_frame.visible = false
	build_show_toggle.visible = false
	build_menu.visible = false


func _open_build_menu():
	build_show_toggle.visible = true
	build_menu.visible = true
	anim_player.play("show_build_menu")
	build_menu_open = true
	ship_grid.visible = true
	ship_build_frame.visible = true
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(camera, "global_position", ship_sprite.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(camera, "zoom", Vector2(0.5, 0.5), 0.5).set_trans(Tween.TRANS_LINEAR)


func _on_dialogic_signal(arg: String):
	match arg:
		"end_event":
			var tween = get_tree().create_tween()
			if event_image:
				tween.tween_property(event_image, "modulate:a", 0, 1.0).set_trans(Tween.TRANS_LINEAR)

			tween.parallel().tween_property(camera, "zoom", Vector2(0.4, 0.4), 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(camera, "global_position", mid_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(background_screen, "modulate:a", 1, 1.0).set_trans(Tween.TRANS_LINEAR)

			build_show_toggle.visible = true
			build_menu.visible = true

			time_control_ui._on_speed_1_button_pressed()

			ResourceManager.check_if_all_crew_died()
			EventManager.check_if_victory()
			TickManager.start_ticks()


		# Hack to end an event with the build menu open for tutorials and such
		"end_event_build":
			var tween = get_tree().create_tween()
			tween.tween_property(background_screen, "modulate:a", 1, 1.0).set_trans(Tween.TRANS_LINEAR)
			if event_image:
				tween.tween_property(event_image, "modulate:a", 0, 1.0).set_trans(Tween.TRANS_LINEAR)

			build_show_toggle.visible = true
			build_menu.visible = true

			time_control_ui._on_speed_1_button_pressed()

			ResourceManager.check_if_all_crew_died()
			EventManager.check_if_victory()
			TickManager.start_ticks()

		"open_build_screen":
			_open_build_menu()


func change_event_image(texture_path: String):
	if texture_path == "":
		event_image.texture = null
	else:
		event_image.texture = load(texture_path)


func change_objective_label(text: String):
	objective_label.text = "Objective: " + text


func _on_debug_event_menu_button_item_selected(index):
	# Adjust for separator items
	var id = debug_event_dropdown.get_item_id(index)
	EventManager.play_specific_event_resource(
		EventManager.event_resources[id]
	)
	debug_event_dropdown.select(-1)

