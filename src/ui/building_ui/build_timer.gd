extends Control

@onready var icon = $CenterContainer/BuildTimerUI/CenterContainer/HBoxContainer/TextureRect
@onready var label = $CenterContainer/BuildTimerUI/CenterContainer/HBoxContainer/Label


func _ready():
	self.pivot_offset = self.size / 2


func _process(delta):
	self.rotation = get_parent().rotation * -1

