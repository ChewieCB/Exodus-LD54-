extends Node

var tutorial_progress = 0 # -1 = disable tutorial, 0 = enable tutorial
var tick_since_last_event = 0
var tick_to_event = 20
var tick_passed_total = 0
var end_game = false

var distance_travelled = 0
var distance_to_victory = 200

var ship_hull_level = 1

enum TRAVEL_PATH_TYPE {
	DEFAULT_PATH,
	INTERGALATIC_ROUTE,
	ASTEROID_FIELD,
	VOID_FIELD
}

var chosen_path: TRAVEL_PATH_TYPE = TRAVEL_PATH_TYPE.DEFAULT_PATH

# primary storyline
var primary_story_date = [10, 50, 100, 150]
var primary_story_id = 0:
	set(value):
		primary_story_id = value
		emit_signal("primary_story_id_changed")
# General event markers
signal start_event
signal dialogic_signal
# Event UI updates
signal request_change_event_image
signal request_change_objective_label
# Negation zone
signal negation_zone
signal trigger_negation_zone(flag)
signal proximity_alert(ticks_left)
# Win state
signal victory
# 
signal primary_story_id_changed
# Starmap travel events
signal star_arrived(star)
signal star_event(star)
signal tutorial_neighbor_star_event
# Build view
signal enable_build_view(state)
signal focus_build_buttons(tab, button_indexes)
signal unlock_build_buttons
# Command view
signal enable_command_view(state)
signal change_command_tab(idx)
# - Research
signal show_research_tree(idx)
# - Starmap
signal unlock_travel_screen
signal docking_release

@export var encounter_events: Array[ExodusEvent]
@export var debug_events: Array[ExodusEvent]
@export var tutorial_events: Array[ExodusEvent]
@export var primary_story_events: Array[ExodusEvent]
@export var victory_event: ExodusEvent
#
var previous_background: Texture2D = null
#
@onready var available_events: Array[ExodusEvent] = encounter_events.duplicate()
var completed_events: Array[ExodusEvent]
var event_dict = {} # Dictionary, format int : ExodusEvent (example: {0: tutorial_event_0}). Use in debug event dropdown
var is_in_event = false

@onready var planets = {
	ExodusEvent.PlanetType.WET_TERRAIN: preload("res://addons/pixel_planet_generator/Planets/Rivers/Rivers.tscn"),
	ExodusEvent.PlanetType.DRY_TERRAIN: preload("res://addons/pixel_planet_generator/Planets/DryTerran/DryTerrain.tscn"),
	ExodusEvent.PlanetType.ISLAND: preload("res://addons/pixel_planet_generator/Planets/LandMasses/LandMasses.tscn"),
	ExodusEvent.PlanetType.NO_ATMOSPHERE: preload("res://addons/pixel_planet_generator/Planets/NoAtmosphere/NoAtmosphere.tscn"),
	ExodusEvent.PlanetType.GAS_PLANET: preload("res://addons/pixel_planet_generator/Planets/GasPlanet/GasPlanet.tscn"),
	ExodusEvent.PlanetType.GAS_PLANET_RING: preload("res://addons/pixel_planet_generator/Planets/GasPlanetLayers/GasPlanetLayers.tscn"),
	ExodusEvent.PlanetType.ICE_WORLD: preload("res://addons/pixel_planet_generator/Planets/IceWorld/IceWorld.tscn"),
	ExodusEvent.PlanetType.LAVA_WORLD: preload("res://addons/pixel_planet_generator/Planets/LavaWorld/LavaWorld.tscn"),
	ExodusEvent.PlanetType.ASTEROID: preload("res://addons/pixel_planet_generator/Planets/Asteroids/Asteroid.tscn"),
	ExodusEvent.PlanetType.BLACK_HOLE: preload("res://addons/pixel_planet_generator/Planets/BlackHole/BlackHole.tscn"),
	ExodusEvent.PlanetType.GALAXY: preload("res://addons/pixel_planet_generator/Planets/Galaxy/Galaxy.tscn"),
	ExodusEvent.PlanetType.STAR: preload("res://addons/pixel_planet_generator/Planets/Star/Star.tscn")
}

const MIN_TICK_FOR_EVENT = 6
const MAX_TICK_FOR_EVENT = 20


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	TickManager.tick.connect(check_tick_for_random_event)
	tick_to_event = randi_range(MIN_TICK_FOR_EVENT, MAX_TICK_FOR_EVENT)
	emit_signal("trigger_negation_zone", false)

	# Remove the debug event from the available array
	available_events.pop_front()

func _on_dialogic_signal(arg: String):
	emit_signal("dialogic_signal", arg)


func _enable_command_view(state_string: String):
	var state = str_to_var(state_string)
	emit_signal("enable_command_view", state)


func _enable_build_view(state_string: String):
	var state = str_to_var(state_string)
	emit_signal("enable_build_view", state)

# TUTORIAL signal emitter functions

func _focus_build_buttons(tab_string: String, idx_string: String=""):
	var tab: int
	if tab_string == "-1":
		tab = -1
	else:
		tab = EnumAutoload.BuildingType.get(tab_string)
	var idx = str_to_var(idx_string)
	emit_signal("focus_build_buttons", tab, idx)


func _show_research_tree(idx_string: String):
	var idx = str_to_var(idx_string)
	emit_signal("show_research_tree", idx)


func _unlock_build_buttons():
	emit_signal("unlock_build_buttons")


func _unlock_travel_screen():
	emit_signal("unlock_travel_screen")


func _change_command_tab(idx):
	emit_signal("change_command_tab", str_to_var(idx))


func get_random_event():
	randomize()
	var rand_index = randi() % available_events.size()
	if available_events:
		var event: ExodusEvent = available_events.pop_at(rand_index)
		completed_events.push_back(event)

		return event
	else:
		return null


func play_event(event: ExodusEvent) -> Node:
	change_event_image(event.event_image, event.planet_type)
	var timeline = event.build_dialogic_timeline()
	emit_signal("start_event", event)
	var dialog = Dialogic.start(timeline)
	return dialog

func play_event_by_name(event_name: String) -> Node:
	var event: ExodusEvent = null
	for e in encounter_events:
		if e.name.to_lower() == event_name.to_lower():
			event = e
			break
	if event != null:
		return play_event(event)
	return null

# Currently not in use
func play_event_legacy(event_name: String) -> Node:
	return call(event_name)

func change_event_image(_texture: Texture2D, planet_type: ExodusEvent.PlanetType):
	emit_signal("request_change_event_image", _texture, planet_type)


func change_objective_label(text: String):
	emit_signal("request_change_objective_label", text)


func check_tick_for_random_event():
	# Don't fire events during the tutorial
	if tutorial_progress != -1:
		return
	# Tick equal days passed
	tick_since_last_event += 1
	tick_passed_total += 1
	# print("Tick left for event ", tick_to_event - tick_since_last_event)

	if primary_story_id <= len(primary_story_date) - 1 and tick_passed_total >= primary_story_date[primary_story_id] - 1:
		tick_to_event += 1 # Delay normal event a day to prevent stuff happened same time
		match primary_story_id:
			1:
				if BuildingManager.check_if_building_exist("CryoPod"):
					play_event(primary_story_events[primary_story_id])
			2:
				if BuildingManager.check_if_building_exist("CryoPodArray"):
					play_event(primary_story_events[primary_story_id])
			3:
				if BuildingManager.check_if_building_exist("CryoPodHub"):
					play_event(primary_story_events[primary_story_id])
			_:
				play_event(primary_story_events[primary_story_id])
		primary_story_id += 1

	if tick_since_last_event >= tick_to_event and not end_game:
		tick_since_last_event = 0
		tick_to_event = randi_range(MIN_TICK_FOR_EVENT, MAX_TICK_FOR_EVENT)
		play_event(get_random_event())


func tutorial_add_neighbor_star_event():
	emit_signal("tutorial_neighbor_star_event")


func disable_tutorial():
	tutorial_progress = -1
	change_objective_label("Travel to the target star system near the galaxy center")
	emit_signal("trigger_negation_zone", true)
	emit_signal("unlock_travel_screen")
	ResourceManager.set_is_resource_tick_disabled("false")
	_enable_command_view("true")
	_enable_build_view("true")


func play_victory_event():
	if not end_game:
		end_game = true
		emit_signal("victory")
		play_event(victory_event)


func reset_state():
	tutorial_progress = -1
	tick_since_last_event = 0
	tick_passed_total = 0
	end_game = false
	tick_to_event = randi_range(MIN_TICK_FOR_EVENT, MAX_TICK_FOR_EVENT) + 5


func play_space_fact_event():
	var _events = space_fact_event().split("\n")
	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = _events
	var exodus_event: ExodusEvent = ExodusEvent.new()
	exodus_event.active_screen = ExodusEvent.ACTIVE_SCREEN.NAV
	exodus_event.name = "Space fact"
	exodus_event.type = ExodusEvent.EVENT_TYPES.SELF
	emit_signal("start_event", exodus_event)
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


func _trigger_negation_zone(value: bool):
	emit_signal("trigger_negation_zone", value)


func reached_a_star(star: StarNode, is_goal: bool = false):
	emit_signal("star_arrived", star)
	if is_goal:
		play_event(primary_story_events[-1])
	elif star.has_signal:
		star.has_signal = false
		if star.connected_event:
			play_event(star.connected_event)

