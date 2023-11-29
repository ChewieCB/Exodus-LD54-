extends Node

var first_name_list: Array[String] = ["Aiden", "Sofia", "Ahmed", "Mei", "Alejandro", "Priya", "Luca", "Fatima", "Gabriel", "Aisha", "Hiroshi", 
	"Isabella", "Raj", "Zara", "Mateo", "Leila", "Juan", "Aaliyah", "Chen", "Amir", "Nia", "Rafael", "Amina", "Thiago", "Freya", "Diego", "Amara", "Anton", 
	"Lila", "Carlos", "Ananya", "Niko", "Sana", "Kai", "Surya", "Sofia", "Arjun", "Layla", "Sebastian", "Yara", "Felix", "Fatima", "Matteo", "Aisha", "Hugo", 
	"Zainab", "Emilia", "Jamal", "Maya", "Elina", "Santiago", "Anya", "Kian", "Zoya", "Leo", "Mei", "Owen", "Inara", "Lucas", "Kavi", "Emma", "Arnav", "Grace", 
	"Eliana", "Amir", "Eva", "Jayden", "Ayesha", "Adrian", "Lam", "Leo", "Aria", "Rafael", "Suri", "Ethan", "Anaya", "Isaac", "Priya", "Maya", "Nolan", "Amara", 
	"Kaden", "Alia", "Samuel", "Nyla", "Dylan", "Nur", "Elara", "Luka", "Selma", "Jonah", "Dalia", "Milan", "Amira", "Caleb", "Safiya", "Jasper", "Layla", "Oliver", "Amina"]

var last_name_list: Array[String] = ["Smith", "Kim", "Patel", "Yamamoto", "Rodriguez", "Gupta", "Rossi", "Ali", "Hernandez", "Chen", "Novak", 
	"Nguyen", "Khan", "Ivanov", "Martinez", "Kowalski", "Brown", "Silva", "Singh", "Tanaka", "Mendoza", "Schmidt", "Lee", "Almeida", "Sato", "Gonzalez", "Wu", 
	"Fernandez", "Dubois", "Lopez", "Jansen", "Cohen", "Kaur", "Johnson", "Oliveira", "Costa", "Kimura", "Taylor", "Park", "Anderson", "Garcia", "Yamada", "Adams", 
	"Kobayashi", "Reyes", "Nascimento", "Wilson", "Santos", "Nowak", "Thomas", "Mishra", "Fischer", "Abreu", "Kim", "Becker", "Ramos", "Li", "Pereira", "Smith", "Das", 
	"Morales", "Taylor", "Ahmed", "Oliveira", "Walker", "Khan", "Dubois", "Rodriguez", "Patel", "Yilmaz", "Garcia", "Santos", "Smith", "Chen", "Nascimento", "Tan", 
	"Gonzalez", "Kimura", "Kumar", "Williams", "Ito", "Lee", "Alves", "Suzuki", "Park", "Fernandez", "Yamamoto", "Lee", "Wang", "Rodriguez", "Lima", "Kim", "Lopez", 
	"Sato", "Dubois", "Das", "Park", "Martinez"]

var random_thoughts_list: Array[String] = []
var portrait_list: Array[Resource] = []

var current_crewmates: Array[CrewmateData] = []

func _ready() -> void:
	ResourceManager.population_changed.connect(update_current_crewmates)
	load_resources()
	reset_state()
	

func generate_a_random_crewmate(joined_date: int = 0):
	randomize()
	var new_crewmate = CrewmateData.new()
	var first_name = first_name_list[randi() % first_name_list.size()]
	var last_name = first_name_list[randi() % first_name_list.size()]
	new_crewmate.crewmate_name = first_name + " " + last_name
	new_crewmate.portrait = portrait_list[randi() % portrait_list.size()]
	new_crewmate.age = randi_range(20, 50)
	new_crewmate.backstory = "Backstory go here..."
	new_crewmate.joined_date = joined_date
	new_crewmate.random_thought = random_thoughts_list[randi() % random_thoughts_list.size()]
	return new_crewmate

func add_crewmates(amount: int = 1):
	var date = EventManager.tick_passed_total + 1
	for i in range(amount):
		var new_crewmate = generate_a_random_crewmate(date)
		current_crewmates.append(new_crewmate)

func remove_crewmates_by_name(fullname: String):
	for crewmate in current_crewmates:
		if crewmate.crewmate_name == fullname:
			current_crewmates.erase(crewmate)

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


func load_resources():
	# Random thoughts
	var file = FileAccess.open("res://src/managers/crewmate_manager/random_thoughts.txt", FileAccess.READ)
	if file.is_open():
		# Read the file line by line
		while !file.eof_reached():
			var line = file.get_line()
			random_thoughts_list.append(line)
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

	
func update_random_thoughts():
	for cm in current_crewmates:
		cm.random_thought = random_thoughts_list[randi() % random_thoughts_list.size()]
