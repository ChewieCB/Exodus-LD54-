extends Node2D

@onready var star_particles = $Space/StarCPUParticles2D

# We don't use the same variable in EventManager to avoid race condition
var n_hab_built = 0
var n_food_built = 0


func _ready():
	# Set initial resources
	ResourceManager.housing_amount = 0
	ResourceManager.food_amount = 150
	ResourceManager.water_amount = 250
	ResourceManager.air_amount = 200
	#
	TickManager.tick_changed.connect(_update_star_particles)
	#
	ScreenTransitionManager.fade_in(1.5)

	# For tutorial only
	EventManager.building_finished.connect(tutorial_tracker)

	await ScreenTransitionManager.transitioned
	#
	TickManager.start_ticks()


func tutorial_tracker(type: Building.TYPES):
	if EventManager.tutorial_progress >= 2 :
		return

	match type:
		Building.TYPES.HabBuilding:
			n_hab_built += 1
		Building.TYPES.FoodBuilding:
			n_food_built += 1	

	if n_food_built >= 2 and EventManager.tutorial_progress == 0:
		EventManager.play_specific_event("tutorial2_event")
		EventManager.tutorial_progress = 1
		return
	if n_hab_built >= 2:
		if EventManager.tutorial_progress == 1:
			EventManager.play_specific_event("tutorial3_event")
			EventManager.tutorial_progress = 2
		elif EventManager.tutorial_progress == -1:
			EventManager.play_specific_event("disabled_tutorial_event")
			EventManager.tutorial_progress = 2
		return

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
	if EventManager.tutorial_progress == 0:
		EventManager.play_specific_event("tutorial1_event")
