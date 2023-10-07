extends Node

signal tick
signal tick_changed(tick_speed, is_paused)

@onready var tick_timer = $Timer

const SLOW_TICK_SPEED = 5.0
const FAST_TICK_SPEED = 1.25
var current_tick_rate = SLOW_TICK_SPEED
var time_control_ui = null

func _ready():
	tick_timer.start(SLOW_TICK_SPEED)
	tick_timer.set_paused(true)


func start_ticks():
	tick_timer.set_paused(false)
	emit_signal("tick_changed", current_tick_rate, false)


func stop_ticks():
	tick_timer.set_paused(true)
	emit_signal("tick_changed", current_tick_rate, true)


func _set_tick_rate(new_tick_rate: float):
	if new_tick_rate == current_tick_rate:
		return

	tick_timer.set_paused(true)
	if time_control_ui != null:
		time_control_ui.saved_progress = time_control_ui.tick_progress_bar.value
	# Remap the progress on one timescale to another
	var remapped_time_left = remap(
		tick_timer.time_left,
		0, current_tick_rate,
		0, new_tick_rate
	)
	remapped_time_left = clamp(remapped_time_left, 0, new_tick_rate)
	current_tick_rate = new_tick_rate
	emit_signal("tick_changed", current_tick_rate, false)
	tick_timer.set_paused(false)
	tick_timer.start(remapped_time_left)


func _on_timer_timeout():
	print("tick")
	emit_signal("tick")
	if time_control_ui != null:
		time_control_ui.saved_progress = 0
	if not tick_timer.wait_time == current_tick_rate:
		tick_timer.start(current_tick_rate)


func reset_state():
	current_tick_rate = SLOW_TICK_SPEED
	tick_timer.start(SLOW_TICK_SPEED)
	tick_timer.set_paused(true)
