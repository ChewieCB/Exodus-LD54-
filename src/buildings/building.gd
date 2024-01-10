extends Node2D
class_name Building

signal building_finished_operation

@export var data: BuildingResource

@onready var sprite = $Sprite2D
@onready var collider = $Area2D
@onready var build_timer_ui = $BuildTimerUI

@onready var pulse_shader = preload("res://src/buildings/shaders/pulse.gdshader")
@onready var build_start_sfx = preload("res://assets/audio/sfx/Building_Start.mp3")
@onready var build_finish_sfx = preload("res://assets/audio/sfx/Building_Finish.mp3")
@onready var cant_place_sfx = preload("res://assets/audio/sfx/Cant_Place_Building_There.mp3")

# Build menu vars
var preview = false
var outside_gridmap = false
var original_color: Color
var placeable = false
@export var placed = false

# Building process vars
var is_constructing: bool = false
var ticks_left_to_build: int
@export var building_complete: bool = false

# Deletion
var can_delete: bool = true
var is_deconstructing: bool = false
var ticks_left_to_delete: int
var is_hover = false

var bonus_multiplier: float = 1


func _ready():
	set_original_color()
	build_timer_ui.visible = false
	TickManager.tick.connect(_on_tick)
	ResourceManager.upgrade_acquired.connect(check_for_adjacency_multiplier)
	check_for_adjacency_multiplier()

	if placed and building_complete:
		_setup_scan_for_nearby_bonus()

	# Setup shader material for buildings
	var pulse_mat = ShaderMaterial.new()
	pulse_mat.shader = pulse_shader
	if sprite.get_child_count() > 0:
		for _sprite in sprite.get_children():
			_sprite.material = pulse_mat
			_sprite.material.set_shader_parameter("mode", 0)
	else:
		sprite.material = pulse_mat
		sprite.material.set_shader_parameter("mode", 0)

func _unhandled_input(event):
	if event.is_action_released("cancel_place_building"):
		if data.type == EnumAutoload.BuildingType.SECTOR:
			return
		if is_hover and can_delete and not preview:
			if is_constructing and not is_deconstructing:
				cancel_construction()
			elif building_complete and is_deconstructing:
				cancel_deconstruction()
			else:
				set_building_remove()

func _process(delta):
	if not placed and preview:
		if collider.has_overlapping_areas() or collider.has_overlapping_bodies() or outside_gridmap:
			color_sprite(1, 0, 0, 0.5)
			placeable = false
		else:
			color_sprite(0, 1, 0, 0.5)
			placeable = true

func check_for_adjacency_multiplier(_unused_var = null):
	# Wait 2 frame to make sure all Area2D changes are setup correctly
	await get_tree().physics_frame
	await get_tree().physics_frame

	bonus_multiplier = 1
	for area in collider.get_overlapping_areas():
		# Warehouse bonus
		if area.get_parent() is WarehouseBuilding:
			var nearby_warehouse = area.get_parent() as WarehouseBuilding
			if EnumAutoload.UpgradeId.CONSTRUCTION_LOGIC_STOCK_ANALYSIS in ResourceManager.current_upgrades:
				var warehouse_resource_bonus = nearby_warehouse.get_resource_bonus_prod()
				match(data.type):
					EnumAutoload.BuildingType.WATER:
						bonus_multiplier += warehouse_resource_bonus.water
					EnumAutoload.BuildingType.AIR:
						bonus_multiplier += warehouse_resource_bonus.air
					EnumAutoload.BuildingType.FOOD:
						bonus_multiplier += warehouse_resource_bonus.food
					EnumAutoload.BuildingType.METAL:
						bonus_multiplier += warehouse_resource_bonus.metal

func construct_in_progress():
	# Update the building to show it's under construction
	var pulse_colour = Color("#ffd4a3")
	pulse_colour.a = 0.5
	sprite.material.set_shader_parameter("shine_color", pulse_colour)
	sprite.material.set_shader_parameter("full_pulse_cycle", true)
	sprite.material.set_shader_parameter("mode", 1)
	#
	BuildingManager.construction_queue.push_front(self)


func deconstruct_in_progress():
	var deconstruct_colour: Color = Color("#853519")
	deconstruct_colour.a = 0.5
	sprite.material.set_shader_parameter("shine_color", deconstruct_colour)
	sprite.material.set_shader_parameter("full_pulse_cycle", true)
	sprite.material.set_shader_parameter("mode", 1)
	#
	BuildingManager.construction_queue.push_front(self)

func _setup_scan_for_nearby_bonus():
	if data.type in [EnumAutoload.BuildingType.CRYO_POD, EnumAutoload.BuildingType.STORAGE]:
		return

	collider.set_collision_mask_value (3, true)
	BuildingManager.building_finished.connect(check_for_adjacency_multiplier)
	BuildingManager.building_deconstructed.connect(check_for_adjacency_multiplier)

func _on_tick():
	if not placed:
		return
	if not building_complete and is_constructing:
		if ticks_left_to_build <= 1:
			add_building()
		else:
			ticks_left_to_build -= 1
			build_timer_ui.label.text = str(ticks_left_to_build)
	elif is_deconstructing:
		if ticks_left_to_delete <= 1:
			remove_building()
		else:
			ticks_left_to_delete -= 1
			build_timer_ui.label.text = str(ticks_left_to_delete)

func add_building():
	building_complete = true
	is_constructing = false
	is_deconstructing = false
	build_timer_ui.visible = false
	ResourceManager.add_building(self)
	ResourceManager.retrieve_workers(self)
	BuildingManager.construction_queue.erase(self)
	BuildingManager.finished_building(data.type)
	SoundManager.play_sound(build_finish_sfx, "SFX")
	sprite.material.set_shader_parameter("mode", 0)
	emit_signal("building_finished_operation")

func remove_building():
	build_timer_ui.visible = false
	if is_constructing or is_deconstructing:
		ResourceManager.retrieve_workers(self)
	BuildingManager.construction_queue.erase(self)
	SoundManager.play_sound(build_finish_sfx, "SFX")
	deconstructed_refund_resource()
	emit_signal("building_finished_operation")
	BuildingManager.finished_deconstruct_building(data.type)
	self.queue_free()

func deconstructed_refund_resource():
	if data.type == EnumAutoload.BuildingType.CRYO_POD:
		ResourceManager.population_amount += data.refund_population

func start_constructing():
	remove_improved_preview()
	is_constructing = true
	placed = true
	preview = false
	ResourceManager.assign_workers(self)
	ResourceManager.change_resource(data.resource_cost, false, ResourceManager.get_build_cost_with_upgrade_multiplier())
	# Restore the building's true colour outside of preview UI
	color_sprite(original_color.r, original_color.g, original_color.b, original_color.a)
	# Update build timer/construction effects
	ticks_left_to_build = ResourceManager.calculate_build_time_with_upgrade(data.construction_time)
	build_timer_ui.label.text = str(ticks_left_to_build)
	build_timer_ui.visible = true
	construct_in_progress()
	SoundManager.play_sound(build_start_sfx, "SFX")
	_setup_scan_for_nearby_bonus()

func set_building_remove():
	if ResourceManager.worker_amount >= data.people_cost:
		is_deconstructing = true
		# Costs workers to deconstruct
		ResourceManager.assign_workers(self)
		# Update build timer/construction effects
		ticks_left_to_delete = ResourceManager.calculate_build_time_with_upgrade(data.destruction_time)
		build_timer_ui.label.text = str(ticks_left_to_delete)
		build_timer_ui.visible = true
		deconstruct_in_progress()
		SoundManager.play_sound(build_start_sfx, "SFX")
	else:
		BuildingManager.emit_signal("not_enough_workers")
		SoundManager.play_sound(cant_place_sfx, "SFX")

# Cancel a building that is constructing
func cancel_construction(no_refund=false):
	is_constructing = false
	build_timer_ui.visible = false
	if not no_refund:
		ResourceManager.retrieve_workers(self)
		ResourceManager.change_resource(data.resource_cost, true, ResourceManager.get_build_cost_with_upgrade_multiplier())
	BuildingManager.construction_queue.erase(self)
	SoundManager.play_sound(build_finish_sfx, "SFX")
	self.queue_free()

# Cancel a building that is de-constructing
func cancel_deconstruction(no_refund=false):
	is_deconstructing = false
	build_timer_ui.visible = false
	if not no_refund:
		ResourceManager.retrieve_workers(self)
	BuildingManager.construction_queue.erase(self)
	SoundManager.play_sound(build_finish_sfx, "SFX")
	sprite.material.set_shader_parameter("mode", 0)


func get_produced_resource() -> ResourceData:
	var prod_res = ResourceData.new()
	prod_res.food = ceil(data.resource_prod.food * bonus_multiplier)
	prod_res.water = ceil(data.resource_prod.water * bonus_multiplier)
	prod_res.air = ceil(data.resource_prod.air * bonus_multiplier)
	prod_res.metal = ceil(data.resource_prod.metal * bonus_multiplier)

	return prod_res

func enable_improved_preview():
	# For override
	return

func remove_improved_preview():
	# For override
	return


func set_original_color():
	if sprite is Sprite2D:
		original_color = sprite.modulate
	elif sprite is Node2D and sprite.get_child_count() > 0:
		original_color = sprite.get_children()[0].modulate


func color_sprite(r, g, b, a):
	if sprite is Sprite2D:
		sprite.modulate = Color(r, g, b, a)
	elif sprite is Node2D and sprite.get_child_count() > 0:
		# This is a group of rectangle, used in testing only
		for item in sprite.get_children():
			item.modulate = Color(r, g, b, a)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			on_predelete()


func on_predelete() -> void:
	ResourceManager.remove_building(self)
	if len(BuildingManager.selected_building_queue) > 0 and \
		BuildingManager.selected_building_queue[0] == self:
		BuildingManager.hide_building_info_panel()
		BuildingManager.selected_building_queue.erase(self)


func _on_area_2d_mouse_entered():
	if EventManager.is_in_event:
		return

	BuildingManager.selected_building_queue.append(self)
	# print(self.data.name + " selected")
	var pulse_colour = Color("#ffffff")
	pulse_colour.a = 0.5
	if sprite.get_child_count() > 0:
		for _sprite in sprite.get_children():
			_sprite.material.set_shader_parameter("shine_color", pulse_colour)
			_sprite.material.set_shader_parameter("full_pulse_cycle", true)
			_sprite.material.set_shader_parameter("mode", 1)
	else:
		sprite.material.set_shader_parameter("shine_color", pulse_colour)
		sprite.material.set_shader_parameter("full_pulse_cycle", true)
		sprite.material.set_shader_parameter("mode", 1)
	enable_improved_preview()
	is_hover = true


func _on_area_2d_mouse_exited():
	BuildingManager.selected_building_queue.erase(self)
	if sprite.get_child_count() > 0:
		for _sprite in sprite.get_children():
			_sprite.material.set_shader_parameter("mode", 0)
	else:
		sprite.material.set_shader_parameter("mode", 0)
	remove_improved_preview()
	is_hover = false

func rotate_cw():
	rotation += PI/2

func get_context_menu_name() -> String:
	return data.name

func get_context_menu_description() -> String:
	var tmp = ""
	match data.type:
		EnumAutoload.BuildingType.HABITATION:
			tmp = "Can house {n_house} crew members.".format({"n_house": data.housing_prod})
		EnumAutoload.BuildingType.FOOD:
			tmp = "Can produce {n_food} units of Food per day.".format({"n_food": get_produced_resource().food})
		EnumAutoload.BuildingType.WATER:
			tmp = "Can produce {n_water} units of Water per day.".format({"n_water": get_produced_resource().water})
		EnumAutoload.BuildingType.AIR:
			tmp = "Can produce {n_air} units of Oxygen per day.".format({"n_air": get_produced_resource().air})
		EnumAutoload.BuildingType.METAL:
			tmp = "Can produce {n_metal} units of Metal per day.".format({"n_metal": get_produced_resource().metal})
		EnumAutoload.BuildingType.CRYO_POD:
			tmp = "Can be deconstructed to wake up {n_pop} crew member(s).".format({"n_pop": data.refund_population})
		EnumAutoload.BuildingType.SECTOR:
			tmp = "Can be cleared to increase building area."
	return tmp

func get_context_menu_stat() -> String:
	var tmp = ""
	if not data.type == EnumAutoload.BuildingType.SECTOR:
		tmp = "Construct time: {0} day(s), {1} crewmate(s)\n".format([ResourceManager.calculate_build_time_with_upgrade(data.construction_time), data.people_cost])
	tmp += "Deconstruct time: {0} day(s), {1} crewmate(s)".format([ResourceManager.calculate_build_time_with_upgrade(data.destruction_time), data.people_cost])
	if bonus_multiplier > 1:
		tmp += "\nCurrent multiplier: {mul}%".format({"mul": bonus_multiplier * 100})
	return tmp
