extends Node

signal tick
signal tick_changed(tick_speed, is_paused)

@onready var tick_timer = $Timer

const SLOW_TICK_SPEED = 5.0
const FAST_TICK_SPEED = 1.5
var current_tick_rate = SLOW_TICK_SPEED


#func _ready():
#	_set_tick_rate(SLOW_TICK_SPEED)


func start_ticks():
	tick_timer.set_paused(false)
	emit_signal("tick_changed", current_tick_rate, false)


func stop_ticks():
	tick_timer.set_paused(true)
	emit_signal("tick_changed", current_tick_rate, true)


func _set_tick_rate(value: float):
	tick_timer.set_paused(true)
	# Remap the progress on one timescale to another
	var remapped_time_left = remap(
		tick_timer.time_left, 
		0, tick_timer.wait_time,
		0, value
	)
	remapped_time_left = clamp(remapped_time_left, 0, value)
	# Update the timer
	tick_timer.wait_time = value
	current_tick_rate = value
	#
	emit_signal("tick_changed", current_tick_rate, false)
	tick_timer.set_paused(false)
	tick_timer.start(remapped_time_left)


func _on_timer_timeout():
	print("tick")
	emit_signal("tick")
	if not tick_timer.wait_time == current_tick_rate:
		tick_timer.start(current_tick_rate)
