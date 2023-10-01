extends Node

func get_random_element_from_array(options: Array):
	randomize()
	var rand_index:int = randi() % options.size()

	if options[rand_index]:
		return options[rand_index]


func test_planet_event() -> String:
	var planet_color = get_random_element_from_array(["red", "blue", "green", "silver"])
	var resource_type = get_random_element_from_array(["oxygen", "metal", "water"])

	var event_source_text = """
	[background arg="res://assets/backgrounds/planet.jpg" fade="0.0"]
	You passed a {planet_color} planet. They look like has a lot of {resource_type} to harvert!
	What would you do?
	- Haverst
		You harvested 10 unit of {resource_type}
	- Ignore
		It not worth the risk you supposed. You continued on your journey
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"planet_color"=planet_color, "resource_type"=resource_type})
	return event_source_text

func plague_planet() -> String:
	var event_source_text = """
	[background arg="res://assets/backgrounds/planet.jpg" fade="0.0"]
	You received a signal after passed through an Earth-like planet. The signal need to be decrypted before you understand it.
	- Decrypt it (cost 1 Energy)
		It's a signal asking for help. Look like a spaceship crashed onto this place.__get_property_list
		- Send a squad to help (cost 1 Food, 1 Water)
			Your squad successfully rescued them, but to your horror, you discovered they are infected with some kind of space plague. And your rescue squad may be already infected now, you never know.
			- Abandon them all, not worth the risk
				You ditched everyone. What a tragedy, but you cannot risk the colony.
			- Abandon the refugee, let the squad back
				Let's hope they are not infected yet.
			- Abandon the refugee, treat the squad (Cost 2 Food, 2 Water)
				You can just let your citizen die, you will treat them. The refugee? Nah, not worth it. The infection sample help your research department a bit, so that not too bad.
				You lost 2 Food, 2 Water. You gained 2 Science.
			- Try to save all of them, give everyone proper treatment (Cost 6 Food, 6 Water)
				We are all human here. Let try to help each other.
				You lost 6 Food, 6 Water. You gained 5 People, 2 Science. 
		- Ignore and move on
			The ship don't have space nor resource for more people. Let's move on.
	- Ignore and move on
		You ignored the signal and move on.
	[signal arg="end_event"]
	"""
	return event_source_text

func get_random_event() -> DialogicTimeline:
	var method_name = get_random_element_from_array(["plague_planet"])
	var event_source_text = call(method_name)
	var events : Array = event_source_text.split('\n')
	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = events
	return timeline
