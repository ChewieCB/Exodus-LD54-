extends Control

@onready var label = $CenterContainer/BuildTimerUI/CenterContainer/PanelContainer/MarginContainer/HBoxContainer/Label


func _ready():
	self.pivot_offset = self.size / 2


func update_rotation():
	self.rotation = get_parent().rotation * -1

