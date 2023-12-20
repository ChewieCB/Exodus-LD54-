extends Node2D

@onready var star_particles = $Space/StarCPUParticles2D
@export var tutorial_disabled: bool = false

var is_ship_hover: bool = false
@onready var ship_no_highlight: Color = Color(1.0, 1.0, 1.0, 1.0)
@onready var ship_highlight: Color = Color(1.5, 1.5, 1.5, 1.0)

# We don't use the same variable in EventManager to avoid race condition
var n_hab_built = 0
var n_food_built = 0
var bgm_audio_player: AudioStreamPlayer
var bgm_music

signal ship_selected
signal ship_deselected


func _ready():
	TickManager.tick_changed.connect(_update_star_particles)
	EventManager.building_finished.connect(tutorial_tracker)
	if tutorial_disabled:
		EventManager.tutorial_progress = -1

	ScreenTransitionManager.fade_in(1.5)
	await ScreenTransitionManager.transitioned

	bgm_music = load("res://assets/audio/music/ld54-bgm-medley-no-alarms-1.1.mp3")
	bgm_audio_player = SoundManager.play_music(bgm_music, 0.2, "Music")
	bgm_audio_player.finished.connect(play_bgm_again)

	get_tree().paused = false
	get_node("UI").visible = true


func _physics_process(_delta):
	# We can only call get_world_2d().direct_space_state safely 
	# in the physics frame, hence why this logic is here 
	# instead of _input.
	if Input.is_action_just_pressed("cancel_place_building"):
		# Don't exit build view if we have a building preview active
		if $ShipSprite/ShipGrid.current_building:
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


func tutorial_tracker(type: Building.TYPES):
	if EventManager.tutorial_progress >= 2 or EventManager.tutorial_progress <= -1 :
		return

	match type:
		Building.TYPES.HabBuilding:
			n_hab_built += 1
		Building.TYPES.FoodBuilding:
			n_food_built += 1

	if n_food_built >= 2 and EventManager.tutorial_progress == 0:
		EventManager.play_event(EventManager.tutorial_events[1])
		EventManager.tutorial_progress = 1
		return
	if n_hab_built >= 2:
		if EventManager.tutorial_progress == 1:
			EventManager.play_event(EventManager.tutorial_events[2])
			EventManager.tutorial_progress = 2


func _update_star_particles(tick_speed, is_paused):
	var tween = get_tree().create_tween()
	if is_paused:
		tween.tween_property(
			star_particles, "speed_scale", 0, 0.55
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	else:
		match tick_speed:
			TickManager.SLOW_TICK_SPEED:
				tween.tween_property(
					star_particles, "speed_scale", 1, 0.35
				).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			TickManager.FAST_TICK_SPEED:
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
