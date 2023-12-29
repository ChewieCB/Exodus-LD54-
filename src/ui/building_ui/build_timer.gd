extends Control

@onready var label = $CenterContainer/BuildTimerUI/CenterContainer/PanelContainer/MarginContainer/HBoxContainer/Label
@onready var icon = $CenterContainer/BuildTimerUI/CenterContainer/PanelContainer/MarginContainer/HBoxContainer/TextureRect

func _ready():
	self.pivot_offset = self.size / 2


func update_rotation():
	self.rotation = get_parent().rotation * -1

func set_color(color: Color):
	label.self_modulate = color
	icon.self_modulate = color

func set_text(text: String):
	label.text = text

