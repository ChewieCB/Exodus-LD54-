extends MarginContainer
class_name Alert

@onready var icon = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/IconContainer/Icon
@onready var label = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/DescContainer/Description
@onready var countdown_sep = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VSeparator2
@onready var countdown = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/CountdownContainer
@onready var countdown_text = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/CountdownContainer/Countdown
@onready var anim_player = $AnimationPlayer


enum TYPE {
	POPULATION,
	WORKER,
	FOOD,
	WATER,
	AIR
}

@export var type: TYPE:
	set(value):
		type = value
		match type:
			TYPE.POPULATION:
				icon.texture = load("res://assets/ui/icons/final_icons/pop_icon.png")
			TYPE.WORKER:
				icon.texture = load("res://assets/ui/icons/final_icons/worker_icon.png")
			TYPE.FOOD:
				icon.texture = load("res://assets/ui/icons/final_icons/food_icon.png")
			TYPE.WATER:
				icon.texture = load("res://assets/ui/icons/final_icons/water_icon.png")
			TYPE.AIR:
				icon.texture = load("res://assets/ui/icons/final_icons/air_icon.png")
		
@export var alert_text: String = "":
	set(value):
		alert_text = value
		label.text = alert_text
@export var has_countdown: bool = false


func _ready():
	match type:
		TYPE.POPULATION:
			icon.texture = load("res://assets/ui/icons/final_icons/pop_icon.png")
		TYPE.WORKER:
			icon.texture = load("res://assets/ui/icons/final_icons/worker_icon.png")
		TYPE.FOOD:
			icon.texture = load("res://assets/ui/icons/final_icons/food_icon.png")
		TYPE.WATER:
			icon.texture = load("res://assets/ui/icons/final_icons/water_icon.png")
		TYPE.AIR:
			icon.texture = load("res://assets/ui/icons/final_icons/air_icon.png")
	
	label.text = alert_text
	
	if has_countdown:
		countdown_sep.visible = true
		countdown.visible = true
	else:
		countdown_sep.visible = false
		countdown.visible = false
