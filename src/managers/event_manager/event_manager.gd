extends Node

signal planet_event(id: int)
signal refugee_event(id: int)

func trigger_planet_event(id: int):
    emit_signal("planet_event", id)

func trigger_refugee_event(id: int):
    emit_signal("refugee_event", id)