extends MarginContainer
class_name MoraleEffectDetailUI

var text: String
var effect: MoraleEffect

@onready var label = $Label


func _ready():
	label.text = text
