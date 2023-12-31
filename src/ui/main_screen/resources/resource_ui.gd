extends Control

@onready var population_counter = $HBoxContainer/MarginContainer/HBoxContainer/PopContainer/HBoxContainer/PopLabel
@onready var worker_counter = $HBoxContainer/MarginContainer/HBoxContainer/WorkerContainer/HBoxContainer/WorkerLabel
@onready var hab_label: Label = $HBoxContainer/MarginContainer5/HBoxContainer/HabDebug
@onready var food_label: Label = $HBoxContainer/MarginContainer2/HBoxContainer/FoodDebug
@onready var water_label: Label = $HBoxContainer/MarginContainer3/HBoxContainer/WaterDebug
@onready var air_label: Label = $HBoxContainer/MarginContainer4/HBoxContainer/AirDebug
@onready var metal_label: Label = $HBoxContainer/MarginContainer6/HBoxContainer/MetalLabel

@export var resource_change_popup: PackedScene

var old_pop_value = 0
var old_housing_value = 0
var old_food_value = 0
var old_water_value = 0
var old_air_value = 0
var old_metal_value = 0
var old_storage_value: ResourceData

func _ready():
	ResourceManager.population_changed.connect(_update_pop_ui)
	ResourceManager.workers_changed.connect(_update_worker_ui)
	ResourceManager.housing_changed.connect(_update_housing_ui)
	#
	ResourceManager.food_modifier_changed.connect(_update_debug_food)
	ResourceManager.water_modifier_changed.connect(_update_debug_water)
	ResourceManager.air_modifier_changed.connect(_update_debug_air)
	ResourceManager.metal_modifier_changed.connect(_update_debug_metal)
	#
	ResourceManager.population_changed.connect(spawn_pop_change_popup)
	ResourceManager.housing_changed.connect(spawn_housing_change_popup)
	ResourceManager.food_changed.connect(spawn_food_change_popup)
	ResourceManager.water_changed.connect(spawn_water_change_popup)
	ResourceManager.air_changed.connect(spawn_air_change_popup)
	ResourceManager.metal_changed.connect(spawn_metal_change_popup)

	var base_storage = ResourceManager.BASE_STORAGE
	old_storage_value = ResourceData.new(base_storage, base_storage, base_storage, base_storage)
	ResourceManager.storage_changed.connect(spawn_storage_change_popup)

	# This is fucking stupid, but it's 1AM, i'm tired, and it fixes the UI update problem
	ResourceManager.population_amount = ResourceManager.population_amount
	ResourceManager.worker_amount = ResourceManager.worker_amount

	old_pop_value = ResourceManager.population_amount
	old_housing_value = ResourceManager.housing_amount
	old_food_value = ResourceManager.food_amount
	old_water_value = ResourceManager.water_amount
	old_air_value = ResourceManager.air_amount
	old_metal_value = ResourceManager.metal_amount


func animate_bar(bar, value) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(
		bar, "value", value, 0.4
	).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)


func _update_pop_ui(value):
	population_counter.text = str(value)

func _update_worker_ui(value):
	worker_counter.text = str(value)

func _update_housing_ui(total, available):
	hab_label.text = "{0} ({1})".format([str(total), str(available)])
	old_housing_value = total

func _update_debug_food(total, modifier):
	var modifier_str = str(round(modifier))
	var modifier_prefix = ""
	if modifier > 0:
		modifier_prefix = "+"
	food_label.text = "{0} ({1}{2})".format([str(round(total)), modifier_prefix, modifier_str])
	old_food_value = total

func _update_debug_water(total, modifier):
	var modifier_str = str(round(modifier))
	var modifier_prefix = ""
	if modifier > 0:
		modifier_prefix = "+"
	water_label.text = "{0} ({1}{2})".format([str(round(total)), modifier_prefix, modifier_str])
	old_water_value = total

func _update_debug_air(total, modifier):
	var modifier_str = str(round(modifier))
	var modifier_prefix = ""
	if modifier > 0:
		modifier_prefix = "+"
	air_label.text = "{0} ({1}{2})".format([str(round(total)), modifier_prefix, modifier_str])
	old_air_value = total

func _update_debug_metal(total, modifier):
	var modifier_str = str(round(modifier))
	var modifier_prefix = ""
	if modifier > 0:
		modifier_prefix = "+"
	metal_label.text = "{0} ({1}{2})".format([str(round(total)), modifier_prefix, modifier_str])
	old_metal_value = total

func spawn_pop_change_popup(total):
	spawn_resource_change_popup(total - old_pop_value, population_counter)
	old_pop_value = total

func spawn_housing_change_popup(total, available):
	spawn_resource_change_popup(total - old_housing_value, hab_label)
	old_housing_value = total

func spawn_food_change_popup(total):
	spawn_resource_change_popup(total - old_food_value, food_label)
	old_food_value = total

func spawn_water_change_popup(total):
	spawn_resource_change_popup(total - old_water_value, water_label)
	old_water_value = total

func spawn_air_change_popup(total):
	spawn_resource_change_popup(total - old_air_value, air_label)
	old_air_value = total

func spawn_metal_change_popup(total):
	spawn_resource_change_popup(total - old_metal_value, metal_label)
	old_metal_value = total

func spawn_storage_change_popup(total: ResourceData):
	spawn_resource_change_popup(total.food - old_storage_value.food, food_label, "\nCapacity")
	spawn_resource_change_popup(total.water - old_storage_value.water, water_label, "\nCapacity")
	spawn_resource_change_popup(total.air - old_storage_value.air, air_label, "\nCapacity")
	spawn_resource_change_popup(total.metal - old_storage_value.metal, metal_label, "\nCapacity")
	old_storage_value = total

func spawn_resource_change_popup(change_amount: int, parent_node: Node, suffix_text: String = ""):
	if change_amount == 0:
		return
	var new_popup = resource_change_popup.instantiate()
	if change_amount > 0:
		new_popup.modulate = Color.GREEN
		new_popup.get_node("Label").text = "+" + str(change_amount) + suffix_text
	else:
		new_popup.modulate = Color.RED
		new_popup.get_node("Label").text = str(change_amount) + suffix_text
	new_popup.position.x += randi_range(-15, 15)
	new_popup.position.y += randi_range(-10, 10)
	parent_node.add_child(new_popup)


func _on_pop_ui_mouse_entered():
	ResourceManager.emit_signal("ui_hover_show", "Available Crew members - Total Crew memebers")

func _on_resource_ui_mouse_exited():
	ResourceManager.emit_signal("ui_hover_hide")

func _on_hab_ui_mouse_entered():
	ResourceManager.emit_signal("ui_hover_show", "Housing (Available Housing)")

func _on_food_ui_mouse_entered():
	ResourceManager.emit_signal("ui_hover_show", "Food (Food per Day)\n{current} / {max}".format({"current": ResourceManager.food_amount, "max": ResourceManager.storage_resource_amount.food}))

func _on_water_ui_mouse_entered():
	ResourceManager.emit_signal("ui_hover_show", "Water (Water per Day)\n{current} / {max}".format({"current": ResourceManager.water_amount, "max": ResourceManager.storage_resource_amount.water}))

func _on_air_ui_mouse_entered():
	ResourceManager.emit_signal("ui_hover_show", "Oxygen (Oxygen per Day)\n{current} / {max}".format({"current": ResourceManager.air_amount, "max": ResourceManager.storage_resource_amount.air}))

func _on_metal_ui_mouse_entered():
	ResourceManager.emit_signal("ui_hover_show", "Metal (Metal per Day)\n{current} / {max}".format({"current": ResourceManager.metal_amount, "max": ResourceManager.storage_resource_amount.metal}))

