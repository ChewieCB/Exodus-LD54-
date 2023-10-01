extends Node

signal tick

@onready var tick_timer = $Timer

const SLOW_TICK_SPEED = 5.0
const FAST_TICK_SPEED = 1.5


func _ready():
	_set_tick_rate(SLOW_TICK_SPEED)


func start_ticks():
	tick_timer.start()


func stop_ticks():
	tick_timer.stop()


func _set_tick_rate(value: float):
	tick_timer.wait_time = value


func _on_timer_timeout():
	print("tick")
	emit_signal("tick")
