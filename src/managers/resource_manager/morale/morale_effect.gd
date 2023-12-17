extends Node
class_name MoraleEffect

enum TYPES {
	EnvironmentalMoraleEffect,
	TemporaryMoraleEffect
}

@export var data: MoraleEffectResource:
	set(value):
		data = value
		if data:
			_name = data._name
			type = data.type
			morale_modifier_value = data.morale_modifier_value
			effect_length = data.effect_length
			
@export var _name: String = "Name not set"
@export var type: TYPES = TYPES.TemporaryMoraleEffect
@export var morale_modifier_value: int = 0
@export var effect_length: int = 1:
	set(value):
		effect_length = value
		ticks_left = effect_length

var ticks_left: int = effect_length:
	set(value):
		ticks_left = value
		if ticks_left == -1:
			ResourceManager.remove_morale_effect(self)


func end_environmental_effect():
	if type == TYPES.EnvironmentalMoraleEffect:
		queue_free()


func _on_tick():
	ticks_left -= 1

