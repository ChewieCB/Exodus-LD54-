extends MarginContainer
class_name Alert

@onready var panel = $VBoxContainer/MarginContainer/PanelContainer
@onready var icon = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/IconContainer/Icon
@onready var label = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/DescContainer/Description
@onready var countdown_sep = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VSeparator2
@onready var countdown = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/CountdownContainer
@onready var countdown_text = $VBoxContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/CountdownContainer/Countdown
@onready var anim_player = $AnimationPlayer
@onready var timer: Timer = $Timer


var type: EnumAutoload.AlertType
var alert_text: String = ""
var has_countdown: bool = false
var countdown_value: int = 10
var has_timer_destroy: bool = false

func _ready():
	update_alert_status()
	label.text = alert_text
	if has_countdown:
		countdown_sep.visible = true
		countdown.visible = true
		countdown_text.text = str(countdown_value)
	else:
		countdown_sep.visible = false
		countdown.visible = false
		countdown_text.text = ""
	if has_timer_destroy:
		timer.start()

func update_alert_status():
	match type:
		EnumAutoload.AlertType.POPULATION:
			icon.texture = load("res://assets/ui/icons/final_icons/pop_icon.png")
		EnumAutoload.AlertType.WORKER:
			icon.texture = load("res://assets/ui/icons/final_icons/worker_icon.png")
		EnumAutoload.AlertType.FOOD:
			icon.texture = load("res://assets/ui/icons/final_icons/food_icon.png")
		EnumAutoload.AlertType.WATER:
			icon.texture = load("res://assets/ui/icons/final_icons/water_icon.png")
		EnumAutoload.AlertType.AIR:
			icon.texture = load("res://assets/ui/icons/final_icons/air_icon.png")
		EnumAutoload.AlertType.MORALE:
			icon.texture = load("res://assets/ui/icons/final_icons/pop_icon.png")
		EnumAutoload.AlertType.PROXIMITY:
			icon.texture = null
			var new_stylebox = panel.get_theme_stylebox("panel")
			new_stylebox.bg_color = Color.DARK_RED
		EnumAutoload.AlertType.RESEARCH:
			icon.texture = null
			var new_stylebox = panel.get_theme_stylebox("panel")
			new_stylebox.bg_color = Color.DARK_GREEN

func remove_alert():
	anim_player.play("alert_out")
	await anim_player.animation_finished
	timer.stop()
	queue_free()

func _on_timer_timeout():
	remove_alert()


func _on_button_pressed() -> void:
	remove_alert()
