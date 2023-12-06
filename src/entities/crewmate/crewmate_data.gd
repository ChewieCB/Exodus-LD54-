extends Resource
class_name CrewmateData

var crewmate_name: String
var age: int
var joined_date: int
var portrait: Texture2D
var random_thought: String
var status: EnumAutoload.CrewmateStatus

func _init(p_crewmate_name = "", p_age = 0, p_joined_date = 0, p_portrait = null, 
	p_random_thought = "", p_status = EnumAutoload.CrewmateStatus.HEALTHY):
	crewmate_name = p_crewmate_name
	age = p_age
	joined_date = p_joined_date
	portrait = p_portrait
	random_thought = p_random_thought
	status = p_status

