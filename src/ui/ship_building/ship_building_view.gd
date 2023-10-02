extends Node2D

@onready var star_particles = $Space/StarGPUParticles2D


func _ready():
	# Set initial resources
	ResourceManager.housing_amount = 0
	ResourceManager.food_amount = 50
	ResourceManager.water_amount = 250
	ResourceManager.air_amount = 200
	#
	TickManager.tick_changed.connect(_update_star_particles)
	#
	ScreenTransitionManager.fade_in(1.5)
	await ScreenTransitionManager.transitioned
	#
	TickManager.start_ticks()


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
