extends Node

var n_hab_building = 0
var n_food_building = 0
var n_water_building = 0
var n_air_building = 0

var tutorial_progress = 0 # -1 = disable tutorial, 0 = enable tutorial
var tick_since_last_event = 0
var tick_to_event = 20
var tick_passed_total = 0
var tick_to_victory = 199
var end_game = false

const MIN_TICK_FOR_EVENT = 6
const MAX_TICK_FOR_EVENT = 20

signal building_finished
signal start_event
signal request_change_event_image
signal request_change_objective_label
signal victory

@export var event_resources: Array[Event]
@export var tutorial_events: Array[Event]
@export var victory_event: Event
#
@export var planet_backgrounds: Array[Texture2D]
@export var ship_backgrounds: Array[Texture2D]
@export var space_backgrounds: Array[Texture2D]
var previous_background: Texture2D = null
#
@onready var available_events: Array[Event] = event_resources.duplicate()
var completed_events: Array[Event]


func _ready() -> void:
	TickManager.tick.connect(check_tick_for_random_event)
	tick_to_event = randi_range(MIN_TICK_FOR_EVENT, MAX_TICK_FOR_EVENT)
	
	# Remove the debug event from the available array
	available_events.pop_front()
	
	if tutorial_progress == 0:
		tick_to_event += 5


func finished_building(type: Building.TYPES):
	emit_signal("building_finished", type)
	match type:
		Building.TYPES.HabBuilding:
			n_hab_building += 1
		Building.TYPES.FoodBuilding:
			n_food_building += 1
		Building.TYPES.WaterBuilding:
			n_water_building += 1
		Building.TYPES.AirBuilding:
			n_air_building += 1


func get_random_event():
	randomize()
	var rand_index = randi() % available_events.size()
	if available_events:
		var event: Event = available_events.pop_at(rand_index)
		completed_events.push_back(event)
		
		return event
	else:
		return null


func get_random_background(type):
	var background_array
	match type:
		Event.EVENT_TYPES.PLANET:
			background_array = planet_backgrounds
		Event.EVENT_TYPES.SHIP:
			background_array = ship_backgrounds
		_:
			background_array = space_backgrounds
	
	randomize()
	var rand_index = randi() % background_array.size()
	var background = background_array[rand_index]
	# Prevent showing the same background twice in a row
	if previous_background and background_array.size() > 1:
		while background == previous_background:
			rand_index = randi() % background_array.size()
			background = background_array[rand_index]
	
	previous_background = background
	
	return background


func play_event(event: Event) -> Node:
	if event.background:
		change_event_image(event.background)
	else:
		change_event_image(get_random_background(event.type))
	var timeline = event.build_dialogic_timeline()
	emit_signal("start_event", event)
	var dialog = Dialogic.start(timeline)
	return dialog


func change_event_image(_texture: Texture2D):
	emit_signal("request_change_event_image", _texture)


func change_objective_label(text: String):
	emit_signal("request_change_objective_label", text)


func check_tick_for_random_event():
	tick_since_last_event += 1
	tick_passed_total += 1
	print("Tick left for event ", tick_to_event - tick_since_last_event)

	if tick_passed_total >= tick_to_victory and not end_game:
		end_game = true
		play_event(victory_event)
		return

	if tick_since_last_event >= tick_to_event and not end_game:
		tick_since_last_event = 0
		tick_to_event = randi_range(MIN_TICK_FOR_EVENT, MAX_TICK_FOR_EVENT)
		play_event(get_random_event())


func disable_tutorial():
	tutorial_progress = -1
	change_objective_label("Survive until day 200")


func check_if_victory():
	if tick_passed_total >= tick_to_victory and end_game:
		emit_signal("victory")


func reset_state():
	n_hab_building = 0
	n_food_building = 0
	n_water_building = 0
	n_air_building = 0
	
	tutorial_progress = -1
	tick_since_last_event = 0
	tick_passed_total = 0
	end_game = false
	tick_to_event = randi_range(MIN_TICK_FOR_EVENT, MAX_TICK_FOR_EVENT) + 5


# TODO - refactor these fact events into Resource Objects 

func play_space_fact_event():
	var _events = space_fact_event().split("\n")
	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = _events
	emit_signal("start_event", "Space Fact")
	var dialog = Dialogic.start(timeline)
	return dialog


func space_fact_event():
	var fact_pool = ["The Milky Way Galaxy, which is home to our solar system, contains over 100 billion stars.",
	"Space is completely silent because there is no air or atmosphere to carry sound waves.",
	"The largest volcano in the solar system is Olympus Mons, located on Mars. It is nearly 13.6 miles (22 kilometers) high, which is almost three times the height of Mount Everest.",
	"The Great Red Spot on Jupiter is a massive storm that has been raging for at least 350 years, and it's so large that it could fit three Earths inside of it.",
	"Astronauts experience 'space sickness', a condition similar to motion sickness, when they first enter space due to the absence of gravity.",
	"The Hubble Space Telescope, launched in 1990, has provided stunning images and valuable data about the universe and has made over 1.4 million observations.",
	"Saturn's rings are not solid but are made up of countless small particles of ice and rock, ranging in size from tiny grains to several meters in diameter.",
	"Space is not completely empty; it contains extremely low-density particles and radiation, including cosmic rays and micrometeoroids.",
	"The speed of light in a vacuum is approximately 186,282 miles per second (299,792 kilometers per second). This is the fastest speed at which information or matter can travel in the universe.",
	"The nearest star system to our solar system is Alpha Centauri, located about 4.37 light-years away. It consists of three stars: Alpha Centauri A, Alpha Centauri B, and Proxima Centauri, the closest-known exoplanetary system to our sun.",
	"Most of the events in this game were coded in 3 hours before the submission deadline.",
	"The dialogue writer for this game is a published novelist. You should go buy his book, it's called The Helios Incident."]
	var random_fact = fact_pool[randi() % fact_pool.size()]
	var event_source_text = """
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Hey Captain, did you know that...
	Join IntercomGuy 4
	IntercomGuy (Normal): {random_fact}
	Leave ExecutiveOfficer
	Leave IntercomGuy
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"random_fact"=random_fact})
	return event_source_text
