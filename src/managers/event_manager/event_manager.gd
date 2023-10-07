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

const MIN_TICK_FOR_EVENT = 15
const MAX_TICK_FOR_EVENT = 30

signal building_finished
signal start_event
signal finish_event
signal request_change_event_image
signal request_change_objective_label
signal victory


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	TickManager.tick.connect(check_tick_for_random_event)
	tick_to_event = randi_range(MIN_TICK_FOR_EVENT, MAX_TICK_FOR_EVENT)
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


# Loop through in order for testing
var current_event_idx = 0
var events = [
	"plague_planet_event",
	"distress_signal_detected",
	"families_seeking_passage",
	"governor_demands_passage",
	"science_team",
	"planetary_customs",
	"hab_riot",
	"damaged_ship_aid",
	"asteroid_cluster",
	"resource_rich_planetoid"
]


func get_next_event():
#	var event = events[current_event_idx]
	play_specific_event("cheat_menu_event")
#	if current_event_idx < 9:
#		current_event_idx += 1

func _on_dialogic_signal(arg: String):
	emit_signal("finish_event", arg)

func get_random_element_from_array(options: Array):
	randomize()
	var rand_index:int = randi() % options.size()

	if options[rand_index]:
		return options[rand_index]

func get_random_event():
	var event_name = get_random_element_from_array(events)
	var event_source_text = call(event_name)
	var _events : Array = event_source_text.split('\n')
	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = _events
	return [timeline, event_name]


func play_random_event() -> Node:
	var res =  get_random_event()
	var timeline = res[0]
	var event_name = res[1]
	emit_signal("start_event", event_name)
	var dialog = Dialogic.start(timeline)
	return dialog


func get_specific_event(event_name: String) -> DialogicTimeline:
	var event_source_text = call(event_name)
	var _events : Array = event_source_text.split('\n')
	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = _events
	return timeline


func play_specific_event(event_name: String) -> Node:
	var timeline = get_specific_event(event_name)
	emit_signal("start_event", event_name)
	var dialog = Dialogic.start(timeline)
	return dialog


func change_event_image(texture_path: String):
	emit_signal("request_change_event_image", texture_path)


func change_objective_label(text: String):
	emit_signal("request_change_objective_label", text)


func check_tick_for_random_event():
	tick_since_last_event += 1
	tick_passed_total += 1
	print("Tick left for event ", tick_to_event - tick_since_last_event)

	if tick_passed_total >= tick_to_victory and not end_game:
		end_game = true
		play_specific_event("victory_event")
		return

	if tick_since_last_event >= tick_to_event and not end_game:
		tick_since_last_event = 0
		tick_to_event = randi_range(MIN_TICK_FOR_EVENT, MAX_TICK_FOR_EVENT)
		play_random_event()


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
	var random_fact = get_random_element_from_array(fact_pool)
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


func victory_event():
	change_event_image("res://assets/event/Planet_1_Pixel.png")
	var event_source_text = """
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Captain, we've reached the portal system! We're safe!
	ExecutiveOfficer (Normal): The crew stand ready for intergalactic transit. We await your orders.
	- It was an honour and a privilege, Mr Pressley. Set course for the portal. Our new home awaits!
		Leave ExecutiveOfficer
	[signal arg="end_event"]
	"""
	return event_source_text


func asteroid_cluster():
	change_event_image("res://assets/event/Planet_1_Pixel.png")
	var required_resource = randi_range(30, 50)
	var mined_resource = randi_range(20, 40)
	var big_mined_resource = randi_range(80, 120)
	var rm_food = ResourceManager.food_amount
	var rm_water = ResourceManager.water_amount
	var rm_air = ResourceManager.air_amount
	var event_source_text = """
	set {food} = {rm_food}
	set {water} = {rm_water}
	set {air} = {rm_air}
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Captain, message from navigation! Sector charts show a nearby asteroid cluster that was surveyed by Hurulis Asteroid Prospectors.
	ExecutiveOfficer (Normal): A probe sent to the cluster returned with samples of oxygen-rich ores and hydrogen. We can extract them for breathable oxygen and drinkable water. What are your orders?
	- Contact navigation and set a course to the cluster.
		Contact navigation and set a course to the cluster, Pressley. Those resources would help.
		set {chance} = range(1,100).pick_random()
		# 50% chance success
		if {chance} >= 50:
			ExecutiveOfficer (Normal): Our engineers extracted some resources from the asteroid cluster. It's not a lot, but every bit helps.
			[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "{mined_resource}"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "{mined_resource}"]" single_use="true"]
			You gained {mined_resource} Water and Oxygen.
		else:
			ExecutiveOfficer (Normal): Those prospectors knew their stuff! These asteroids were flush with minerals. We've extracted what we can and have returned to our original course.
			[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "{big_mined_resource}"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "{big_mined_resource}"]" single_use="true"]
			You gained {big_mined_resource} Water and Oxygen.
	- Continue on our present course.
		There'll be more opportunities in the future. Continue on our present course.
		ExecutiveOfficer (Normal): Aye, Captain. I've passed your orders to navigation. We are holding course.
	Leave ExecutiveOfficer
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"required_resource"=required_resource, "mined_resource"=mined_resource, "big_mined_resource"=big_mined_resource, "rm_food"=rm_food, "rm_water"=rm_water, "rm_air"=rm_air})
	return event_source_text


func resource_rich_planetoid():
	change_event_image("res://assets/event/Planet_2_Pixel.png")
	var required_resource = randi_range(10, 20)
	var mined_resource = randi_range(10, 30)
	var big_mined_resource = randi_range(40, 80)
	var rm_food = ResourceManager.food_amount
	var rm_water = ResourceManager.water_amount
	var rm_air = ResourceManager.air_amount
	var event_source_text = """
	set {food} = {rm_food}
	set {water} = {rm_water}
	set {air} = {rm_air}
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Captain, our scanners have picked up a planetoid. Probe survey has identified large deposits of oxygen and frozen water.
	ExecutiveOfficer (Normal): A slight course correction would have us intercept the planetoid, and we could mine the largest and most accessible surface deposits. What your order?
	- Chart a course, Pressley. We need those minerals. (Cost {required_resource} Food, Water and Oxygen). [if {food} >= {required_resource} and {water} >= {required_resource} and {air} >= {required_resource}]
		[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "{required_resource}"]" single_use="true"]
		[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "{required_resource}"]" single_use="true"]
		[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "{required_resource}"]" single_use="true"]
		You lost {required_resource} Food, Water and Oxygen.
		set {chance} = range(1,100).pick_random()
		# 50% chance success
		if {chance} >= 50:
			ExecutiveOfficer (Normal): The planetoid was particularly rich, Captain. We found several high-density veins near the surface.
			[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "{big_mined_resource}"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "{big_mined_resource}"]" single_use="true"]
			You gained {big_mined_resource} Water and Oxygen.
		else:
			ExecutiveOfficer (Normal): Our engineers know their stuff, Captain. We've managed to recover a healthy haul of resources from the planetoid.
			[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "{mined_resource}"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "{mined_resource}"]" single_use="true"]
			You gained {mined_resource} Water and Oxygen.
	- We have no time. Continue on our present course.
		ExecutiveOfficer (Normal): Yes, Captain. I've passed the word onto navigation and we are holding course.
	Leave ExecutiveOfficer
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"required_resource"=required_resource, "mined_resource"=mined_resource, "big_mined_resource"=big_mined_resource, "rm_food"=rm_food, "rm_water"=rm_water, "rm_air"=rm_air})
	return event_source_text


func distress_signal_detected() -> String:
	change_event_image("res://assets/event/Ship_wreak_Pixel.png")
	var reward_people = randi_range(1, 3)
	var reward_food = randi_range(40, 70)
	var reward_water = randi_range(40, 70)
	var reward_air = randi_range(40, 70)
	var max_lost_people = clamp(2, 1, ResourceManager.population_amount - 1)
	var lost_people = randi_range(1, max_lost_people)
	var event_source_text = """
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Captain, shortly after arriving in this sector we received a distress signal coming from a marooned ship, the Menelaus.
	ExecutiveOfficer (Normal): According to their signal, the ship was damaged in a micro-meteorite storm. Its engines are disabled and oxygen is running low. They are a short jump from our position.
	ExecutiveOfficer (Normal): Should we help?
	- Prepare a boarding party to help the Menelaus.
		We're here, Pressley. Who knows how long it'll be before another ship comes along.
		Set a course for the Menelaus and scramble engineering.
		set {chance} = range(1,100).pick_random()
		# 75% chance success
		if {chance} >= 25:
			The crew of the Menelaus are grateful for aid, but the ship is beyond repair. They strip the Menelaus for any useful parts and join your crew.
			[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "{reward_people}"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "{reward_water}"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "{reward_food}"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "{reward_air}"]" single_use="true"]
			Gained {reward_people} Crew, {reward_food} Food, {reward_water} Water, {reward_air} Oxygen.
		else:
			It was a trap! On docking with the Menelaus, pirates opened fire and tried to storm our ship! Our security team held them off before they crossed the docking tube and we are away.
			ExecutiveOfficer (Normal): We are sending transmissions to every ship in the system to warn them about the Menelaus.
			[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "-{lost_people}"]" single_use="true"]
			You lost {lost_people} Crew.
	- Leave the Menelaus to her fate.
		Someone else wil come along, Mr Pressley. We'll rebroadcast the message in the hope that others will hear it.
		ExecutiveOfficer (Normal): I understand, Captain. I've ordered communications to retransmit the distress signal and send it in every direction. Hopefully someone will hear it.
	Leave ExecutiveOfficer
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"reward_people"=reward_people, "reward_food"=reward_food, "reward_water"=reward_water, "reward_air"=reward_air, "lost_people"=lost_people})
	return event_source_text


func plague_planet_event() -> String:
	change_event_image("res://assets/event/Planet_1_Pixel.png")
	var rm_population = ResourceManager.population_amount
	var rm_food = ResourceManager.food_amount
	var rm_water = ResourceManager.water_amount

	var event_source_text = """
	set {population} = {rm_population}
	set {food} = {rm_food}
	set {water} = {rm_water}
	You received an encrypted signal from a nearby planet.
	- Decrypt the signal.
		It's a distress signal. It seems a spaceship had to make a crash landing on this planet. The survivors are asking for aid.
		- Send a landing party with supplies to help (Requires 3 Crew, 6 Food and 6 Water). [if {population} >= 3 and {food} >= 6 and {water} >= 6]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "-6"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "-6"]" single_use="true"]
			set {food} -= 6
			set {water} -= 6
			You lost 6 Food, 6 Water.
			Your landing party made contact with the survivors, but report they are infected with a horrible disease! Your landing party has also been exposed.
			- Abandon them all, we cannot risk the safety of the ship (Lose 2 Crew).
				You abandoned the survivors and landing party. Unfortunate, but we cannot risk the ship.
				[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "-3"]" single_use="true"]
				set {population} -= 2
				You lost 2 Crew.
			- Abandon the survivors, but recall the landing party.
				Let's hope they are not infected yet.
			- Abandon the survivors, treat the landing party (Cost 9 Food, 9 Water). [if {food} >= 9 and {water} >= 9]
				Quarantine and treat the landing party, Pressley. The other survivors will have to fend for themselves.
				[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "-9"]" single_use="true"]
				[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "-9"]" single_use="true"]
				set {food} -= 9
				set {water} -= 9
				You lost 9 Food, 9 Water.
			- Quarantine and treat everyone (Lose 21 Food, 21 Water, Gain 5 Crew). [if {food} >= 21 and {water} >= 21]
				Our galaxy is dying, we must help everyone we can.
				[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "-21"]" single_use="true"]
				[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "-21"]" single_use="true"]
				[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "5"]" single_use="true"]
				set {food} -= 21
				set {water} -= 21
				set {population} += 5
				You lost 21 Food, 21 Water. You gained 5 Crew.
		- Ignore and move on
			The ship doesn't have space or the supplies for more crew, Pressley. Let's move on.
	- Ignore and move on
		You ignore the signal and maintain course.
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"rm_population"=rm_population, "rm_food"=rm_food, "rm_water"=rm_water})
	return event_source_text


func science_team() -> String:
	var rm_population = ResourceManager.population_amount
	var rm_available_housing = ResourceManager.available_housing
	var rm_food = ResourceManager.food_amount
	var rm_water = ResourceManager.water_amount
	
	var rm_population_reward = 3

	var event_source_text = """
	set {population} = {rm_population}
	set {available_housing} = {rm_available_housing}
	set {food} = {rm_food}
	set {water} = {rm_water}
	set {population_reward} = rm_population_reward
	
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Captain, we've been approached by Dr Mona Turner. She heard of our mission and made all speed to reach us before we left the sector.
	ExecutiveOfficer (Normal): Dr Turner leads a team of scientists and engineers fleeing the Negation Field, but their ship is not suited for a long journey. They are asking to come aboard and join our crew.
	ExecutiveOfficer (Normal): What are your orders?
	
	- Extend my compliments to Dr Turner and open a docking tube. Tell them to pack light. [if {population_reward} <= {available_housing}]
		ExecutiveOfficer (Normal): Dr Turner and her team have settled in well. She and her team extend their thanks.
		[call_node path="ResourceManager" method="change_resource_from_event" args="["population", {population_reward}]" single_use="true"]
		Leave ExecutiveOfficer
		You gained {population_reward} Crew.
	
	- We have no room for Dr Turner or her team. Extend my apologies and prepare to leave the sector.
		ExecutiveOfficer (Normal): Captain, I've passed your message onto Dr Turner and we're prepared to leave port. We are away.
	
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"rm_population"=rm_population, "rm_food"=rm_food, "rm_water"=rm_water})
	return event_source_text


func hab_riot() -> String:
	change_event_image("res://assets/event/Ship_wreak_Pixel.png")
	var reward_people = randi_range(1, 3)
	var reward_food = randi_range(40, 70)
	var reward_water = randi_range(40, 70)
	var reward_air = randi_range(40, 70)
	var max_lost_people = clamp(2, 1, ResourceManager.population_amount - 1)
	var lost_people = randi_range(1, max_lost_people)
	var event_source_text = """
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Captain, a brawl has broken out among the crew! 
	ExecutiveOfficer (Normal): Security officers quickly responded and broke up the brawl. Fortunately no one was killed and no equipment was damaged. 
	ExecutiveOfficer (Normal): The ringleaders have been identified and await sentencing.
	
	- Brawls don't just happen. Question the ringleaders and find out what their grievances are.
		The ringleaders have no issue with your command of the ship and the brawl was from a buildup of stress and fear. 
		The chance to speak has given the ringleaders a new respect for your command. They have returned to work.
	
	- I will not tolerate brawling on my ship, Mr Pressley. Not now, not ever.
		ExecutiveOfficer (Normal): Captain, the ringleaders have been thrown in the ship's brig. We can leave them on a nearby planet.
		ExecutiveOfficer (Normal): They rest of the crew are grumbling but the message is clear - your command is not to be questioned.
		[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "-2"]" single_use="true"]
		Leave ExecutiveOfficer
		You lost 2 Crew.
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"reward_people"=reward_people, "reward_food"=reward_food, "reward_water"=reward_water, "reward_air"=reward_air, "lost_people"=lost_people})
	return event_source_text


func planetary_customs() -> String:
	change_event_image("res://assets/event/BigPlanet_4_Pixel.png")
	var rm_population = ResourceManager.population_amount
	var rm_food = ResourceManager.food_amount
	var rm_water = ResourceManager.water_amount

	var event_source_text = """
	set {population} = {rm_population}
	set {food} = {rm_food}
	set {water} = {rm_water}
	
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Captain, planetary customs and control has found some irregularities in our docking permits. Our ship has been grounded and we are ordered to remain in port until these irregularities are resolved.
	ExecutiveOfficer (Normal): Lucky for us, this port is badly maintained and poorly guarded. We could gather the crew and slip out without delay.
	ExecutiveOfficer (Normal): What are your orders?
	
	- Gather the crew, Pressley. We'll sneak past port control, take back our ship and leave this system for good.
		set {chance} = range(1,100).pick_random()
		# 50% chance success
		if {chance} >= 50:
			ExecutiveOfficer (Normal): Captain, we've escaped successfully without anyone being the wiser. 
			ExecutiveOfficer (Normal):No doubt that pesky customs official will be surprised when he finds our empty berth.
			Leave ExecutiveOfficer
		else:
			ExecutiveOfficer (Normal): Captain, we escaped successfully, but I regret not all of the crew managed to get on board in time and were detained by port security. 
			ExecutiveOfficer (Normal): We had to leave them behind.
			[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "-2"]" single_use="true"]
			Leave ExecutiveOfficer
			You lost 2 Crew.
	
	- It's not worth the risk. We'll wait until port control gets our documents in order and we will leave as soon as we are able.
		ExecutiveOfficer (Normal): Captain, after a prolonged stay, port control finally have our permit documentation in order. 
		ExecutiveOfficer (Normal): We have been granted permission to board ship and depart. 
		ExecutiveOfficer (Normal): Let's leave this wretched planet behind.
	
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"rm_population"=rm_population, "rm_food"=rm_food, "rm_water"=rm_water})
	return event_source_text


func damaged_ship_aid() -> String:
	change_event_image("res://assets/event/Ship_wreak_Pixel.png")
	var rm_population = ResourceManager.population_amount
	var rm_food = ResourceManager.food_amount
	var rm_water = ResourceManager.water_amount

	var event_source_text = """
	set {population} = {rm_population}
	set {food} = {rm_food}
	set {water} = {rm_water}
	
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Captain, we've received a message from a nearby ship, the Intrepid. It has made an emergency landing on a planet in this system.
	ExecutiveOfficer (Normal): The ship's hull is intact and it seems the only problem is their faulty oxygen generator. We could send some technicians down and help them with repairs.
	ExecutiveOfficer (Normal): What are your orders?
	
	- We have time and crew to spare. 
		Send a memo to engineering, ask for volunteers who willing to go planetside and help the Intrepid with repairs.
		set {chance} = range(1,100).pick_random()
		# 50% chance success
		if {chance} >= 50:
			ExecutiveOfficer (Normal): The technicians have reported back, they advise the Intrepid's oxygen generation is restored. They are on their way back now.
		else:
			ExecutiveOfficer (Normal): The technicians have returned and advise the Intrepid is fully-functional. The Intrepid made haste to leave the system, but not before her captain gave us a parting gift of excess water they harvested on the planet.
			Leave ExecutiveOfficer
			[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "20"]" single_use="true"]
			Gained 20 Water
	
	- We can't spare the time and at least they're safe on that planet. Carry on, Mr Pressley.
		ExecutiveOfficer (Normal): Understood Captain, we're moving on.
	
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"rm_population"=rm_population, "rm_food"=rm_food, "rm_water"=rm_water})
	return event_source_text


func families_seeking_passage() -> String:
	change_event_image("res://assets/event/Ship_wreak_Pixel.png")
	var reward_people = randi_range(1, 3)
	var reward_food = randi_range(40, 70)
	var reward_water = randi_range(40, 70)
	var reward_air = randi_range(40, 70)
	var max_lost_people = clamp(2, 1, ResourceManager.population_amount - 1)
	var lost_people = randi_range(1, max_lost_people)
	
	var rm_available_housing = ResourceManager.available_housing
	var rm_population = ResourceManager.population_amount
	Dialogic.VAR.available_housing = rm_available_housing
	
	var event_source_text = """
	Available Housing = {available_housing}
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Captain, we've been approached by Faroq Khan, the leader of a group of families who are seeking passage. 
	ExecutiveOfficer (Normal): They come from a border colony world that was destroyed by the Negation Field.
	ExecutiveOfficer (Normal): What should we do?
	- Pass on my complements to Mr Khan. Give him our coordinates and prepare a docking tube. [if {available_housing} >= 3]
		ExecutiveOfficer (Normal): Mr Khan and the other refugees have joined the crew. Reports from section leaders advise they are tough and willing to learn. 
		Leave ExecutiveOfficer
		[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "3"]" single_use="true"]
		You gained 3 Crew.
	- Tell Mr Khan we have no room. He'll have to look for another ship.
		ExecutiveOfficer (Normal): Aye, Captain. We have departed the sector. The refugees will have to find someone else.
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"reward_people"=reward_people, "reward_food"=reward_food, "reward_water"=reward_water, "reward_air"=reward_air, "lost_people"=lost_people})
	return event_source_text


func governor_demands_passage() -> String:
	change_event_image("res://assets/event/Planet_3_Pixel.png")
	var reward_people = randi_range(1, 3)
	var reward_food = randi_range(40, 70)
	var reward_water = randi_range(40, 70)
	var reward_air = randi_range(40, 70)
	var max_lost_people = clamp(2, 1, ResourceManager.population_amount - 1)
	var lost_people = randi_range(1, max_lost_people)
	var event_source_text = """
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Captain, the Negation Field is approaching the planet Atrokan IV and riots are breaking out. Martial law has been declared, but military forces are nearly overwhelmed and civil authority is collapsing.
	ExecutiveOfficer (Normal): The Atrokani governor is demanding passage on our ship. We have some space available.
	ExecutiveOfficer (Normal): What are your orders?
		
		- Extend an official invitation to His Excellency, Mr Pressley, and prepare suitable quarters.
			ExecutiveOfficer (Normal): Yes sir. I will prepare quarters that are appropriate for an official of His Excellency's standing. 
			set {chance} = range(1,100).pick_random()
			# 75% chance
			if {chance} >= 25:
				ExecutiveOfficer (Normal): The Atrokani governor has brought a large amount of food from his personal stock planetside. 
				ExecutiveOfficer (Normal): We can siphon some of that for the rest of the crew without the governor noticing.
				Leave ExecutiveOfficer
				[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "20"]" single_use="true"]
				Gained 20 Food.
			else:
				ExecutiveOfficer (Normal): The Atrokani governor has brought a large quantity of food from his personal stock planetside. 
				ExecutiveOfficer (Normal): He has offered to share it with us as thanks for granting him passage. 
				ExecutiveOfficer (Normal): His Excellency is a competent administrator and has made some improvements to our ship's work procedures. 
				ExecutiveOfficer (Normal): Our crew will work more effectively for the next few cycles.
				Leave ExecutiveOfficer
				[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "70"]" single_use="true"]
				Gained 70 Food, Construction Time temporarily reduced.
		
		- Tell His Excellency he can find another ship. We are not at his beck and call.
			ExecutiveOfficer (Normal): Captain, the Atrokani governor did not take your message well, but we departed before he could detain our ship. We are away.
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"reward_people"=reward_people, "reward_food"=reward_food, "reward_water"=reward_water, "reward_air"=reward_air, "lost_people"=lost_people})
	return event_source_text


func tutorial1_event() -> String:
	var event_source_text = """
	A Negation Field has simultaneously surrounded the galaxy. The field is creeping in and swallowing asteroids, nebula, planets, stars and even black holes. 
	No probe returns or transmits once it passes the field's event horizon. Ships, space stations and entire systems go dark every week. 
	Astronomic calculations have pinpointed the field is shrinking down to a single spot - a backwater system far from most space lanes. The galaxy's greatest scientists have constructed a portal that will take us to another galaxy, beyond the Negation Field's reach. 
	You are the captain of an old supply ship making a run for the portal system, hoping to save yourself and your crew from certain death...
	
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Welcome captain, my name is Pressley, your executive officer. My job is to assist you running your Galanthir-class hauler. It's a highly modular and adaptable ship from the shipyards at Ursa Majoris.
	ExecutiveOfficer (Normal): The ship's crew capacity is three. Crew can be housed in habitation blocks. Crew need oxygen, water and food. The more crew you have, the more oxygen, water and food they need. You can modify your ship with structures that increase oxygen, water or food production.
	ExecutiveOfficer (Normal): We have plenty of oxygen and water for our current crew, but our food stocks are running low. Build two vertical farms to increase our food production.
	
	- Build two vertical farms.
		[call_node path="EventManager" method="change_objective_label" args="["Build 2 Food building"]" single_use="true"]
		[signal arg="open_build_screen"]
		Click on the ship or the build button, navigate to Food tab, then choose the Vertical Farm.
		The number next to the crew icon shows the amount of crew needed to build it. The number next to clock icon shows how many days to finish the building. You can build bigger building when you have more crew.
		[signal arg="end_event_build"]
	- Skip tutorial.
		[call_node path="EventManager" method="disable_tutorial" single_use="true"]
		[signal arg="end_event"]
	Leave ExecutiveOfficer
	"""
	return event_source_text


func tutorial2_event() -> String:
	var event_source_text = """
	Join ExecutiveOfficer 0
	[call_node path="EventManager" method="change_objective_label" args="["Survive"]" single_use="true"]
	ExecutiveOfficer (Normal): Greetings, Captain. Our food production is much improved, but we need more crew to make bigger upgrades to the ship. We need more crew habitation blocks.
	ExecutiveOfficer (Normal): Build two more habitation blocks so we can take on more crew.
	- Built two more crew habitation blocks.
		[call_node path="EventManager" method="change_objective_label" args="["Build 2 Habitation building"]" single_use="true"]
		[signal arg="open_build_screen"]
		Leave ExecutiveOfficer
		Similiar to the food production buildings, open the Build menu, navigate to first tab and choose either Hab Block or Dormitory.
	[signal arg="end_event_build"]
	"""
	return event_source_text


func tutorial3_event() -> String:
	var n_survivor = 2
	var event_source_text = """
	Join ExecutiveOfficer 0
	[call_node path="EventManager" method="change_objective_label" args="["Survive"]" single_use="true"]
	ExecutiveOfficer (Normal): Greetings, captain. We have picked up a distress signal from a lifepod. The lifepod has {n_survivor} crew on board and is running low on oxygen. The distress signal says they'll join the crew of any ship who saves them.
	ExecutiveOfficer (Normal): We now have the accommodation facilities to take on extra crew. There are no other ships in the area. We should help and accept their offer to join us, as more crew means we can make more modifications to our ship.
	- Contact the lifepod and welcome them into the crew.
		[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "{n_survivor}"]" single_use="true"]
		You gained {n_survivor} Crew.
		ExecutiveOfficer (Normal): Good work, Captain. We now have more crew, but more crew means we need to produce more oxygen, water and food. From now on, it's important we balance resources with each increase in the number of crew.
		ExecutiveOfficer (Normal): We have limited resources and limited space on our journey, and there'll be others who need help. Use your best judgement, Captain, but watch those resource levels. 
		ExecutiveOfficer (Normal): Navigation has calculated our journey to the portal system will take 200 days. We are in your hands, Captain.
		Join IntercomGuy 4
		IntercomGuy (Normal): Remember, we can only take on extra crew if they are equal to or less than the ship's available housing. For example, if we find five survivors and have four available housing, we cannot recruit any of them. 
		IntercomGuy (Normal): Make sure you always have some free crew habitats.
		[call_node path="EventManager" method="change_objective_label" args="["Survive until day 200"]" single_use="true"]
		Leave ExecutiveOfficer
		Leave IntercomGuy
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"n_survivor"=n_survivor})
	return event_source_text


func disabled_tutorial_event():
	var n_survivor = 2
	var event_source_text = """
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Greetings, captain. We have picked up a distress signal from a lifepod. The lifepod has {n_survivor} crew on board and is running low on oxygen. The distress signal says they'll join the crew of any ship who saves them.
	- Contact the lifepod and welcome them into the crew.
		[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "{n_survivor}"]" single_use="true"]
		You gained {n_survivor} Crew.
	Leave ExecutiveOfficer
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"n_survivor"=n_survivor})
	return event_source_text


func cheat_menu_event() -> String:
	var n_amount = randi_range(1, 100)
	var event_source_text = """
	Cheat menu, choose what you want:
	- Get 1 population
		You get 1 population
		[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "1"]" single_use="true"]
	- Get 1-100 food
		You get {n_amount} food
		[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "{n_amount}"]" single_use="true"]
	- Get 1-100 water
		You get {n_amount} water
		[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "{n_amount}"]" single_use="true"]
	- Get 1-100 air
		You get {n_amount} oxygen
		[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "{n_amount}"]" single_use="true"]
	- Loss 100 each resource
		You lost 100 oxygen, water, food
		[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "-100"]" single_use="true"]
		[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "-100"]" single_use="true"]
		[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "-100"]" single_use="true"]
	- Loss 1 crew member
		You lost 1 crew member
		[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "-1"]" single_use="true"]
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"n_amount"=n_amount})
	return event_source_text


