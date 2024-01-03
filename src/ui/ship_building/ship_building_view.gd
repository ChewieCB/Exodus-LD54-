extends Node2D

@onready var star_particles = $Space/StarCPUParticles2D
@export var tutorial_disabled: bool = false

var is_ship_hover: bool = false
@onready var ship_no_highlight: Color = Color(1.0, 1.0, 1.0, 1.0)
@onready var ship_highlight: Color = Color(1.5, 1.5, 1.5, 1.0)
@onready var ship_grid = $ShipSprite/ShipGrid

# We don't use the same variable in EventManager to avoid race condition
var n_hab_built = 0
var n_air_built = 0
var n_food_built = 0
var n_water_built = 0
var is_crew_boarded: bool = false

var bgm_audio_player: AudioStreamPlayer
var bgm_music

signal ship_selected
signal ship_deselected


func _ready():
	TickManager.tick_changed.connect(_update_star_particles)
	BuildingManager.building_finished.connect(tutorial_tracker)
	ResourceManager.research_completed.connect(tutorial_tracker)
	if tutorial_disabled:
		EventManager.tutorial_progress = -1

	ScreenTransitionManager.fade_in(1.5)
	await ScreenTransitionManager.transitioned
	var music = load("res://assets/audio/music/ld54-bgm-medley-no-alarms-1.1.mp3")
	SoundManager.play_music(music, 0.2, "Music")

	get_tree().paused = false
	get_node("UI").visible = true


func _physics_process(_delta):
	# We can only call get_world_2d().direct_space_state safely 
	# in the physics frame, hence why this logic is here 
	# instead of _input.
	if Input.is_action_just_pressed("cancel_place_building"):
		# Don't exit build view if we have a building preview active
		if ship_grid.current_building:
			return
		# Check if the mouse is over a building collider
		var space = get_world_2d().direct_space_state
		var params = PhysicsPointQueryParameters2D.new()
		params.position = get_global_mouse_position()
		params.collide_with_areas = true
		# Only detect physics layer 2 - buildings
		params.collision_mask = 0b0010
		# Check if there is a collision at the mouse position
		if space.intersect_point(params, 1):
			return
		
		emit_signal("ship_deselected")


func _input(event):
	if event is InputEventMouseButton:
		# Enter build menu when we left click the ship
		if event.button_index == MOUSE_BUTTON_LEFT and \
		event.pressed:
			if is_ship_hover:
				emit_signal("ship_selected")
				$ShipSprite.modulate = ship_no_highlight


func tutorial_tracker(trigger):
	if EventManager.tutorial_progress == -1:
		return
	
	if trigger is EnumAutoload.BuildingType:
		match trigger:
			EnumAutoload.BuildingType.HABITATION:
				n_hab_built += 1
			EnumAutoload.BuildingType.FOOD:
				n_food_built += 1
			EnumAutoload.BuildingType.AIR:
				n_air_built += 1
			EnumAutoload.BuildingType.WATER:
				n_water_built += 1
	
	# Stage 1 - Habs
	# Stage 2 - Air
	if n_hab_built == 3:
		if EventManager.tutorial_progress == 0:
			EventManager.play_event(EventManager.tutorial_events[1])
			EventManager.tutorial_progress = 1
	# Stage 3 - Food
	if n_air_built == 2 and EventManager.tutorial_progress == 1:
		EventManager.play_event(EventManager.tutorial_events[2])
		EventManager.tutorial_progress = 2
	# Stage 4 - Water
	if n_food_built == 2 and EventManager.tutorial_progress == 2:
		EventManager.play_event(EventManager.tutorial_events[3])
		EventManager.tutorial_progress = 3
	# Stage 5 - Crew
	if n_water_built == 2 and EventManager.tutorial_progress == 3:
		EventManager.play_event(EventManager.tutorial_events[4])
		EventManager.tutorial_progress = 4
		await EventManager.finish_event
		is_crew_boarded = true
	# Stage 6 - Research
	if is_crew_boarded and EventManager.tutorial_progress == 4:
		EventManager.play_event(EventManager.tutorial_events[5])
		EventManager.tutorial_progress = 5
	# Stage 7 - Starmap Unlock
	if ResourceManager.has_upgrade(EnumAutoload.UpgradeId.SHIP_INFRA_TIGHTBEAM_COMM) \
	and EventManager.tutorial_progress == 5:
		EventManager.play_event(EventManager.tutorial_events[6])
		EventManager.tutorial_progress = 6
	# Stage 8 - Starmap Navigation
#	if EventManager.tutorial_progress == 6:
#		await EventManager.docking_release
#		EventManager.play_event(EventManager.tutorial_events[7])
#		EventManager.tutorial_progress = 7
	
	


func _update_star_particles(tick_speed, is_paused):
	var tween = get_tree().create_tween()
	if is_paused:
		tween.tween_property(
			star_particles, "speed_scale", 0, 0.55
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	else:
		match tick_speed:
			TickManager.SLOW_TICK_TIME:
				tween.tween_property(
					star_particles, "speed_scale", 1, 0.35
				).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			TickManager.FAST_TICK_TIME:
				tween.tween_property(
					star_particles, "speed_scale", 4, 0.2
				).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_start_tutorial_timer_timeout() -> void:
	if EventManager.tutorial_progress == 0 and not tutorial_disabled:
		EventManager.play_event(EventManager.tutorial_events[0])
	else:
		EventManager.play_event(EventManager.tutorial_events[3]) # start_game_without_tutorial


func play_bgm_again():
	bgm_audio_player = SoundManager.play_music(bgm_music, 0.2, "Music")


func _on_ship_select_area_mouse_entered():
	is_ship_hover = true
	if not $UI/MainUI.build_menu_open:
		$ShipSprite.modulate = ship_highlight


func _on_ship_select_area_mouse_exited():
	is_ship_hover = false
	if not $UI/MainUI.build_menu_open:
		$ShipSprite.modulate = ship_no_highlight
