extends MarginContainer
class_name Alert

@onready var panel = $VBoxContainer/MarginContainer/PanelContainer
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
	AIR,
	MORALE,
	PROXIMITY
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
			TYPE.MORALE:
				icon.texture = load("res://assets/ui/icons/final_icons/pop_icon.png")
#			TYPE.PROXIMITY:
#				icon.texture = null
		
@export var alert_text: String = "":
	set(value):
		alert_text = value
		label.text = alert_text
@export var has_countdown: bool = false:
	set(value):
		has_countdown = value
		if has_countdown:
			countdown_sep.visible = true
			countdown.visible = true
		else:
			countdown_sep.visible = false
			countdown.visible = false
@export var countdown_value: int = 10:
	set(value):
		countdown_value = value
		countdown_text.text = str(countdown_value)


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
		TYPE.MORALE:
			icon.texture = load("res://assets/ui/icons/final_icons/pop_icon.png")
		TYPE.PROXIMITY:
			icon.texture = null
			# FIXME - Make the proximity alert red
			var new_stylebox = panel.get_theme_stylebox("normal").duplicate()
			new_stylebox.bg_color = Color.DARK_RED
			panel.add_theme_stylebox_override("normal", new_stylebox)
	
	label.text = alert_text
	
	if has_countdown:
		countdown_sep.visible = true
		countdown.visible = true
	else:
		countdown_sep.visible = false
		countdown.visible = false
