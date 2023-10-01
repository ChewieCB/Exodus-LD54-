extends Node

signal tick


func start_ticks():
	$Timer.start()


func stop_ticks():
	$Timer.stop()


func _on_timer_timeout():
	emit_signal("tick")
