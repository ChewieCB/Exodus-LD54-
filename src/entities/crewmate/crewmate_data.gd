extends Resource
class_name CrewmateData

var crewmate_name: String
var backstory: String
var age: int # should between 20-50
var joined_date: int

func _init(p_crewmate_name = "", p_backstory = "", p_age = 0, p_joined_date = 0):
	crewmate_name = p_crewmate_name
	backstory = p_backstory
	age = p_age
	joined_date = p_joined_date

