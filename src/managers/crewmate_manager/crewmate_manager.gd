extends Node
# MAKE SURE THIS SCRIPT LOAD BEFORE RESOURCE_MANAGER IN PROJECT AUTOLOAD SETTINGS

signal crewmate_jettisoned(crewmate)

var first_name_list: Array[String] = []
var last_name_list: Array[String] = []
var random_thoughts_list: Array[String] = []
var yeet_thoughts_list: Array[String] = []
var portrait_list: Array[Resource] = []

var current_crewmates: Array[CrewmateData] = []
var already_removed_crewmate = false

const MIN_AGE = 20
const MAX_AGE = 50

func _ready() -> void:
	# MAKE SURE THIS SCRIPT LOAD BEFORE RESOURCE_MANAGER IN PROJECT AUTOLOAD SETTINGS
	load_resources()
	reset_state()


func generate_a_random_crewmate(joined_date: int = 0):
	randomize()
	var new_crewmate = CrewmateData.new()
	var first_name = first_name_list[randi() % first_name_list.size()]
	var last_name = first_name_list[randi() % first_name_list.size()]
	new_crewmate.crewmate_name = first_name + " " + last_name
	new_crewmate.portrait = portrait_list[randi() % portrait_list.size()]
	new_crewmate.age = randi_range(MIN_AGE, MAX_AGE)
	new_crewmate.joined_date = joined_date
	new_crewmate.random_thought = random_thoughts_list[randi() % random_thoughts_list.size()]
	return new_crewmate

func add_crewmates(amount: int = 1):
	var date = EventManager.tick_passed_total + 1
	for i in range(amount):
		var new_crewmate = generate_a_random_crewmate(date)
		current_crewmates.append(new_crewmate)

func remove_crewmates_by_name(fullname: String):
	var chosen_crewmate: CrewmateData
	for crewmate in current_crewmates:
		if crewmate.crewmate_name == fullname:
			chosen_crewmate = crewmate
			current_crewmates.erase(crewmate)
	emit_signal("crewmate_jettisoned", chosen_crewmate)
	# Ignore morale impact of population loss, jettison morale impact should override this
	ResourceManager.set_population_amount(ResourceManager.population_amount - 1, true)

func remove_random_n_crewmates(n: int = 0):
	if n > len(current_crewmates):
		# It gonna be Game Over so it probably doesn't matter that much
		n = len(current_crewmates)

	for i in range(n):
		var x = randi()%len(current_crewmates)
		current_crewmates.remove_at(x)

func reset_state():
	current_crewmates = []
	var initial_pop_amount = 3
	add_crewmates(initial_pop_amount)

func update_current_crewmates(n: int):
	if n > len(current_crewmates):
		add_crewmates(n - len(current_crewmates))
	elif n < len(current_crewmates):
		remove_random_n_crewmates(len(current_crewmates) - n)

func update_random_thoughts():
	for cm in current_crewmates:
		cm.random_thought = random_thoughts_list[randi() % random_thoughts_list.size()]

func set_yeet_thought(fullname: String):
	for crewmate in current_crewmates:
		if crewmate.crewmate_name == fullname:
			crewmate.random_thought = yeet_thoughts_list[randi() % yeet_thoughts_list.size()]

func load_resources():
	# First name
	var file = FileAccess.open("res://src/managers/crewmate_manager/first_name.txt", FileAccess.READ)
	if file.is_open():
		# Read the file line by line
		while !file.eof_reached():
			var line = file.get_line()
			first_name_list.append(line)
		file.close()

	# Last name
	file = FileAccess.open("res://src/managers/crewmate_manager/last_name.txt", FileAccess.READ)
	if file.is_open():
		# Read the file line by line
		while !file.eof_reached():
			var line = file.get_line()
			last_name_list.append(line)
		file.close()

	# Random thoughts
	file = FileAccess.open("res://src/managers/crewmate_manager/random_thoughts.txt", FileAccess.READ)
	if file.is_open():
		# Read the file line by line
		while !file.eof_reached():
			var line = file.get_line()
			random_thoughts_list.append(line)
		file.close()

	# Yeet thoughts
	file = FileAccess.open("res://src/managers/crewmate_manager/yeet_thoughts.txt", FileAccess.READ)
	if file.is_open():
		# Read the file line by line
		while !file.eof_reached():
			var line = file.get_line()
			yeet_thoughts_list.append(line)
		file.close()

	# Portraits
	var portrait_dir_path = "res://assets/character/crewmates/"
	var dir = DirAccess.open(portrait_dir_path)
	dir.list_dir_begin()
	var file_name = dir.get_next()

	while(file_name != ""):
		if file_name.ends_with(".png"):
			if dir.current_is_dir():
				pass
			else:
				var portrait = ResourceLoader.load(portrait_dir_path + "/" + file_name)
				portrait_list.append(portrait)
		file_name = dir.get_next()



