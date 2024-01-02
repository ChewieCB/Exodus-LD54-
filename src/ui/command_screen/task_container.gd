extends MarginContainer
# Not used
@export_multiline var task_text: String
@export_multiline var reward_text: String

@onready var cost_label: Label = $VBoxContainer/CostLabel
@onready var task_label: Label = $VBoxContainer/TaskLabel
@onready var reward_label: Label = $VBoxContainer/RewardLabel
@onready var button: Button = $Button

var required_food = 0
var required_air = 0
var required_water = 0
var required_metal = 0
var task_id = -1

enum TaskIdName {
	REPAIR_SHIP_HULL,
	REPAIR_ENGINE,

}

func _ready() -> void:
	TickManager.tick.connect(check_if_sastify_condition)
	check_if_sastify_condition()
	update_cost_label()
	task_label.text = "Task: " + task_text
	reward_label.text = "Reward: " + reward_text


func update_cost_label():
	cost_label.text = "Cost: "
	if required_food > 0:
		cost_label.text += str(required_food) + " Food"
	if required_food > 0:
		cost_label.text += ", " + str(required_air) + " Air"
	if required_food > 0:
		cost_label.text += ", " + str(required_water) + " Water"
	if required_food > 0:
		cost_label.text += ", " + str(required_metal) + " Metal"

func check_if_sastify_condition():
	if ResourceManager.food_amount >= required_food \
		and ResourceManager.water_amount >= required_water \
		and ResourceManager.air_amount >= required_air \
		and ResourceManager.metal_amount >= required_metal:
		button.visible = true
	else:
		button.visible = false


func _on_button_pressed() -> void:
	apply_reward()
	queue_free()


func apply_reward():
	match task_id:
		0:
			return