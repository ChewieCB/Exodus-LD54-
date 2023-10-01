extends Node

signal planet_event(id: int)
signal refugee_event(id: int)

func trigger_planet_event(id: int):
	emit_signal("planet_event", id)

func trigger_refugee_event(id: int):
	emit_signal("refugee_event", id)


func get_random_element_from_array(options: Array):
	randomize()
	var rand_index:int = randi() % options.size()

	if options[rand_index]:
		return options[rand_index]


func get_random_planet_event() -> DialogicTimeline:
	var planet_color = get_random_element_from_array(["red", "blue", "green", "silver"])
	var resource_type = get_random_element_from_array(["oxygen", "metal", "water"])

	var event_source_text = """
	[background arg="res://assets/backgrounds/planet.jpg" fade="0.0"]
	You passed a {planet_color} planet. They look like has a lot of {resource_type} to harvert!
	- Haverst
		You harvested 10 unit of {resource_type}
	- Ignore
		It not worth the risk you supposed. You continued on your journey
	"""
	event_source_text = event_source_text.format({"planet_color"=planet_color, "resource_type"=resource_type})

	var events : Array = event_source_text.split('\n')

	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = events
	return timeline