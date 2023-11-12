extends Resource
class_name ExodusEvent

# PLANET = events happens on a planet (signal from a planet, go down a planet to get supply)
# SPACE = events happens during space travel (meet other ship, see a rich mineral asteroid)
# SELF = events happens on our ship (ship riot, crew sick, aliens sneak in, main story)
# DEBUG = events for debugging, never appear in normal gameplay
enum EVENT_TYPES {
	PLANET,
	SPACE,
	DEBUG,
	SELF
}

enum ACTIVE_SCREEN {
	BUILD,
	NAV,
	EVENT
}

enum PlanetType {
	NONE,
	WET_TERRAIN, # River
	DRY_TERRAIN,
	LAVA_WORLD,
	ICE_WORLD,
	GAS_PLANET,
	GAS_PLANET_RING, # Gas planet layer
	ISLAND, # Landmasses
	GALAXY,
	BLACK_HOLE,
	NO_ATMOSPHERE,
	STAR,
	ASTEROID
}

@export var name: String
@export var type: EVENT_TYPES
@export var event_image: Texture2D
@export var planet_type: PlanetType = PlanetType.NONE
@export var active_screen: ACTIVE_SCREEN = ACTIVE_SCREEN.EVENT
@export_file("*.txt") var event_text_file
var event_text = ""

# I hope no one saw how we code in this file lol

@export_group("Rewards")
@export_subgroup("1")
@export var pop_reward_1: int
@export var food_reward_1: int
@export var water_reward_1: int
@export var air_reward_1: int
@export var metal_reward_1: int
@export_subgroup("2")
@export var pop_reward_2: int
@export var food_reward_2: int
@export var water_reward_2: int
@export var air_reward_2: int
@export var metal_reward_2: int
@export_subgroup("3")
@export var pop_reward_3: int
@export var food_reward_3: int
@export var water_reward_3: int
@export var air_reward_3: int
@export var metal_reward_3: int
@export_subgroup("4")
@export var pop_reward_4: int
@export var food_reward_4: int
@export var water_reward_4: int
@export var air_reward_4: int
@export var metal_reward_4: int

@export_group("Costs")
@export_subgroup("1")
@export var pop_cost_1: int
@export var food_cost_1: int
@export var water_cost_1: int
@export var air_cost_1: int
@export var metal_cost_1: int
@export_subgroup("2")
@export var pop_cost_2: int
@export var food_cost_2: int
@export var water_cost_2: int
@export var air_cost_2: int
@export var metal_cost_2: int
@export_subgroup("3")
@export var pop_cost_3: int
@export var food_cost_3: int
@export var water_cost_3: int
@export var air_cost_3: int
@export var metal_cost_3: int
@export_subgroup("4")
@export var pop_cost_4: int
@export var food_cost_4: int
@export var water_cost_4: int
@export var air_cost_4: int
@export var metal_cost_4: int

@export_group("Event Chains")
@export var is_chain_event: bool = false
@export_subgroup("Event Chain Properties")
@export var next_chain_event: ExodusEvent


func _init(
	p_name = "", p_type = EVENT_TYPES.SPACE, p_event_image = null,
	p_active_screen = ACTIVE_SCREEN.EVENT,p_event_text_file = "",
	p_pop_reward_1 = 0, p_food_reward_1 = 0, p_water_reward_1 = 0, p_air_reward_1 = 0, p_metal_reward_1 = 0,
	p_pop_reward_2 = 0, p_food_reward_2 = 0, p_water_reward_2 = 0, p_air_reward_2 = 0, p_metal_reward_2 = 0,
	p_pop_reward_3 = 0, p_food_reward_3 = 0, p_water_reward_3 = 0, p_air_reward_3 = 0, p_metal_reward_3 = 0,
	p_pop_reward_4 = 0, p_food_reward_4 = 0, p_water_reward_4 = 0, p_air_reward_4 = 0, p_metal_reward_4 = 0,
	p_pop_cost_1 = 0, p_food_cost_1 = 0, p_water_cost_1 = 0, p_air_cost_1 = 0, p_metal_cost_1 = 0,
	p_pop_cost_2 = 0, p_food_cost_2 = 0, p_water_cost_2 = 0, p_air_cost_2 = 0, p_metal_cost_2 = 0,
	p_pop_cost_3 = 0, p_food_cost_3 = 0, p_water_cost_3 = 0, p_air_cost_3 = 0, p_metal_cost_3 = 0,
	p_pop_cost_4 = 0, p_food_cost_4 = 0, p_water_cost_4 = 0, p_air_cost_4 = 0, p_metal_cost_4 = 0,
	p_is_chain_event = false, p_next_chain_event = null,
):
	name = p_name
	type = p_type
	event_image = p_event_image
	active_screen = p_active_screen
	event_text_file = p_event_text_file

	pop_reward_1 = p_pop_reward_1
	food_reward_1 = p_food_reward_1
	water_reward_1 = p_water_reward_1
	air_reward_1 = p_air_reward_1
	metal_reward_1 = p_metal_reward_1

	pop_reward_2 = p_pop_reward_2
	food_reward_2 = p_food_reward_2
	water_reward_2 = p_water_reward_2
	air_reward_2 = p_air_reward_2
	metal_reward_2 = p_metal_reward_2

	pop_reward_3 = p_pop_reward_3
	food_reward_3 = p_food_reward_3
	water_reward_3 = p_water_reward_3
	air_reward_3 = p_air_reward_3
	metal_reward_3 = p_metal_reward_3

	pop_reward_4 = p_pop_reward_4
	food_reward_4 = p_food_reward_4
	water_reward_4 = p_water_reward_4
	air_reward_4 = p_air_reward_4
	metal_reward_4 = p_metal_reward_4

	pop_cost_1 = p_pop_cost_1
	food_cost_1 = p_food_cost_1
	water_cost_1 = p_water_cost_1
	air_cost_1 = p_air_cost_1
	metal_cost_1 = p_metal_cost_1

	pop_cost_2 = p_pop_cost_2
	food_cost_2 = p_food_cost_2
	water_cost_2 = p_water_cost_2
	air_cost_2 = p_air_cost_2
	metal_cost_2 = p_metal_cost_2

	pop_cost_3 = p_pop_cost_3
	food_cost_3 = p_food_cost_3
	water_cost_3 = p_water_cost_3
	air_cost_3 = p_air_cost_3
	metal_cost_3 = p_metal_cost_3

	pop_cost_4 = p_pop_cost_4
	food_cost_4 = p_food_cost_4
	water_cost_4 = p_water_cost_4
	air_cost_4 = p_air_cost_4
	metal_cost_4 = p_metal_cost_4

	is_chain_event = p_is_chain_event
	next_chain_event = p_next_chain_event


func _update_dialogic_vars() -> void:
	# Resources
	Dialogic.VAR.available_housing = ResourceManager.available_housing
	Dialogic.VAR.population = ResourceManager.population_amount
	Dialogic.VAR.food = ResourceManager.food_amount
	Dialogic.VAR.water = ResourceManager.water_amount
	Dialogic.VAR.air = ResourceManager.air_amount
	Dialogic.VAR.metal = ResourceManager.metal_amount


func build_dialogic_timeline() -> DialogicTimeline:
	# Update Dialogic's variables before we build the timeline
	_update_dialogic_vars()

	# Read in the event text from the file path
	var file = FileAccess.open(event_text_file, FileAccess.READ)
	event_text = file.get_as_text()
	event_text = event_text.format({
		"pop_reward_1"=pop_reward_1, "pop_reward_2"=pop_reward_2, "pop_reward_3"=pop_reward_3, "pop_reward_4"=pop_reward_4,
		"food_reward_1"=food_reward_1, "food_reward_2"=food_reward_2, "food_reward_3"=food_reward_3, "food_reward_4"=food_reward_4,
		"water_reward_1"=water_reward_1, "water_reward_2"=water_reward_2, "water_reward_3"=water_reward_3, "water_reward_4"=water_reward_4,
		"air_reward_1"=air_reward_1, "air_reward_2"=air_reward_2, "air_reward_3"=air_reward_3, "air_reward_4"=air_reward_4,
		"metal_reward_1"=metal_reward_1, "metal_reward_2"=metal_reward_2, "metal_reward_3"=metal_reward_3, "metal_reward_4"=metal_reward_4,
		"pop_cost_1"=pop_cost_1, "pop_cost_2"=pop_cost_2, "pop_cost_3"=pop_cost_3, "pop_cost_4"=pop_cost_4,
		"food_cost_1"=food_cost_1, "food_cost_2"=food_cost_2, "food_cost_3"=food_cost_3, "food_cost_4"=food_cost_4,
		"water_cost_1"=water_cost_1, "water_cost_2"=water_cost_2, "water_cost_3"=water_cost_3, "water_cost_4"=water_cost_4,
		"air_cost_1"=air_cost_1, "air_cost_2"=air_cost_2, "air_cost_3"=air_cost_3, "air_cost_4"=air_cost_4,
		"metal_cost_1"=metal_cost_1, "metal_cost_2"=metal_cost_2, "metal_cost_3"=metal_cost_3, "metal_cost_4"=metal_cost_4,
	})

	var _events : Array = event_text.split('\n')
	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = _events

	return timeline

