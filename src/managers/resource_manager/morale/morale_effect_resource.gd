extends Resource
class_name MoraleEffectResource

@export var _name: String
@export var type: MoraleEffect.TYPES
@export var morale_modifier_value: int = 0
@export var effect_length: int = 1


func _init(
	p_name = "MoraleEffect name not set", 
	p_type = MoraleEffect.TYPES.TemporaryMoraleEffect,
	p_morale_modifier_value = 0, p_effect_length = 1
):
	_name = p_name
	type = p_type
	morale_modifier_value = p_morale_modifier_value
	effect_length = p_effect_length

