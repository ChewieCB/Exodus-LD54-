extends Node

var n_hab_building = 0
var n_food_building = 0
var n_water_building = 0
var n_air_building = 0

var tutorial_progress = 0 # -1 = disable tutorial, 0 = enable tutorial
var tick_since_last_event = 0
var tick_to_event = 20
var tick_passed_total = 0
var tick_to_victory = 200
var end_game = false

const MIN_TICK_FOR_EVENT = 15
const MAX_TICK_FOR_EVENT = 30

signal building_finished
signal start_event
signal request_change_event_image
signal request_change_objective_label
signal victory

func _ready() -> void:
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


func get_random_element_from_array(options: Array):
	randomize()
	var rand_index:int = randi() % options.size()

	if options[rand_index]:
		return options[rand_index]

func get_random_event():
	var event_name = get_random_element_from_array(["asteroid_cluster", "asteroid_cluster", "resource_rich_planetoid", "distress_signal_detected", "plague_planet_event"])
	var event_source_text = call(event_name)
	var events : Array = event_source_text.split('\n')
	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = events
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
	var events : Array = event_source_text.split('\n')
	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = events
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

	if tick_since_last_event >= tick_to_event:
		tick_since_last_event = 0
		tick_to_event = randi_range(MIN_TICK_FOR_EVENT, MAX_TICK_FOR_EVENT)
		play_random_event()

func disable_tutorial():
	tutorial_progress = -1
	change_objective_label("Survive")


func check_if_victory():
	if tick_passed_total >= tick_to_victory and end_game:
		emit_signal("victory")


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
	"Most of the events were coded 2 hours before the submission deadline."]
	var random_fact = get_random_element_from_array(fact_pool)
	var event_source_text = """
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Hey Captain, did you know that...
	ExecutiveOfficer (Normal): {random_fact}
	Leave ExecutiveOfficer
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"random_fact"=random_fact})
	return event_source_text

func victory_event():
	change_event_image("res://assets/event/Planet_1_Pixel.png")
	var event_source_text = """
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Captain, we have arrived at our destination. We survived. Hooray!
	You win the game! Tada!
	Too bad we don't have much time to implement proper victory screen.
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
	ExecutiveOfficer (Normal): Captain, navigation charts have identified an asteroid cluster in this sector that was earmarked for mining by the Hurulis Asteroid Prospectors.
	ExecutiveOfficer (Normal): A probe sent to the cluster has returned with samples of oxygen-rich ores and hydrogen. We can extract these minerals with little effort and synthesize them into breathable oxygen and drinkable water. What are your orders?
	- Contact navigation and chart a safe course through the cluster
		Contact navigation and chart a safe course through the cluster, Pressley. Those resources could be a major help.
		set {chance} = range(1,100).pick_random()
		# 50% chance success
		if {chance} >= 50:
			ExecutiveOfficer (Normal): Our engineers have managed to extract some resources from the asteroid belt. It may not be a lot, but every bit helps.
			[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "{mined_resource}"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "{mined_resource}"]" single_use="true"]
			You gained {mined_resource} Water and Oxygen.
		else:
			ExecutiveOfficer (Normal): Those prospectors knew what they were doing! These asteroids were abundant with resources. We've extracted as much as we can and have returned to our original course.
			[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "{big_mined_resource}"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "{big_mined_resource}"]" single_use="true"]
			You gained {big_mined_resource} Water and Oxygen.
	- Continue on our present course.
		There'll be more opportunities in the future. Continue on our present course.
		ExecutiveOfficer (Normal): Yes, Captain. I've passed the word onto navigation and we are holding course.
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
	ExecutiveOfficer (Normal): Captain, our mid-range scanners have picked up a planetoid. Probe survey has identified large deposits of oxygen and frozen water.
	ExecutiveOfficer (Normal): A slight course correction would have us intercept the planetoid with minimal effort, and we could mine the largest and most accessible surface deposits. What your order?
	- Chart a course. We need those minerals (Cost {required_resource} Food, Water and Oxygen). [if {food} >= {required_resource} and {water} >= {required_resource} and {air} >= {required_resource}]
		[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "{required_resource}"]" single_use="true"]
		[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "{required_resource}"]" single_use="true"]
		[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "{required_resource}"]" single_use="true"]
		You lost {required_resource} Food, Water and Oxygen.
		set {chance} = range(1,100).pick_random()
		# 50% chance success
		if {chance} >= 50:
			ExecutiveOfficer (Normal): The planetoid was particularly rich, Captain, and we found several accessible veins near the surface. Our supplies are looking much better.
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
	ExecutiveOfficer (Normal): According to the signal, the ship was damaged in a micro-meteorite storm. The ship's engines are disabled and oxygen is running low. They are a short jump from our position.
	ExecutiveOfficer (Normal): Should we help the marooned ship or trust that someone else will come along?
	- Help them
		We're here, who knows how long it'll be before another ship comes along.
		Set a course for the Menelaus and scramble medical and engineering teams.
		set {chance} = range(1,100).pick_random()
		# 75% chance success
		if {chance} >= 25:
			The crew of the Menelaus are grateful for aid, but the ship is beyond repair. They strip the Menelaus for parts and join your crew.
			[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "{reward_people}"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "{reward_water}"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "{reward_food}"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "{reward_air}"]" single_use="true"]
			Gained {reward_people} people, {reward_food} Food, {reward_water} Water, {reward_air} Oxygen.
		else:
			It was a trap! On docking with the Menelaus, pirates opened fire and tried to storm our ship! Our security team held them off before they crossed the docking tube and we are away.
			ExecutiveOfficer (Normal): We are sending transmissions to every ship in the system to warn them about the Menelaus.
			[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "-{lost_people}"]" single_use="true"]
			Lost {lost_people} People.
	- Don't help them
		Someone else wil come along, Mr Pressley. We'll rebroadcast the message in the hope that others will hear it.
		ExecutiveOfficer (Normal): I understand, Captain. I've ordered our comms officer to retransmit the distress signal and send it in every direction. I hope that someone else will hear it.
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
	You received a signal after passed through an Earth-like planet. The signal need to be decrypted before you understand it.
	- Decrypt it
		It's a signal asking for help. Look like a spaceship crashed onto this place.
		- Send a squad to help (Required 3 people, cost 6 Food, 6 Water) [if {population} >= 3 and {food} >= 6 and {water} >= 6]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "-6"]" single_use="true"]
			[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "-6"]" single_use="true"]
			set {food} -= 6
			set {water} -= 6
			You lost 6 Food, 6 Water.
			Your squad successfully rescued them, but to your horror, you discovered they are infected with some kind of space plague. And your rescue squad may be already infected now, you never know.
			- Abandon them all, not worth the risk (Lost 2 People)
				You ditched everyone. What a tragedy, but you cannot risk the colony.
				[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "-3"]" single_use="true"]
				set {population} -= 2
				You lost 2 People.
			- Abandon the refugee, let the squad back
				Let's hope they are not infected yet.
			- Abandon the refugee, treat the squad (Cost 9 Food, 9 Water) [if {food} >= 9 and {water} >= 9]
				You can't just let your crew die, you will treat them. The refugee? Nah, not worth it.
				[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "-9"]" single_use="true"]
				[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "-9"]" single_use="true"]
				set {food} -= 9
				set {water} -= 9
				You lost 9 Food, 9 Water.
			- Try to save all of them, give everyone proper treatment (Cost 21 Food, 21 Water, gain 5 people) [if {food} >= 21 and {water} >= 21]
				We are all human here. Let try to help each other.
				[call_node path="ResourceManager" method="change_resource_from_event" args="["food", "-21"]" single_use="true"]
				[call_node path="ResourceManager" method="change_resource_from_event" args="["water", "-21"]" single_use="true"]
				[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "5"]" single_use="true"]
				set {food} -= 21
				set {water} -= 21
				set {population} += 5
				You lost 21 Food, 21 Water. You gained 5 People.
		- Ignore and move on
			The ship don't have space nor resource for more people. Let's move on.
	- Ignore and move on
		You ignored the signal and move on.
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"rm_population"=rm_population, "rm_food"=rm_food, "rm_water"=rm_water})
	return event_source_text

func tutorial1_event() -> String:
	var event_source_text = """
	A negation field has simultaneously surrounded the galaxy. The field is gradually creeping in and swallowing all matter. Stars, nebula, planets, asteroids, even black holes. The Negation Field emits no electromagnetic radiation or heat.
	No probe returns or transmits signals once passing the field's event horizon. Ships, outposts, colonies and settlements go dark every week.
	Astronomic calculations have pinpointed the field is shrinking down to a single spot - a quiet backwater solar system far from most space lanes. You are the captain of a battered old supply ship who has decided to make for this system, believing it is the only hope for the future of the galaxy.
	Join ExecutiveOfficer 0
	ExecutiveOfficer (Normal): Welcome captain, my name is Pressley, your executive officer. My job is to assist you running your Galanthir-class hauler. It's a highly modular and adaptable ship from the shipyards at Ursa Majoris.
	ExecutiveOfficer (Normal): The ship's crew capacity is 3. Crew can be housed in hab blocks. Crew need air, water and food. The more crew you have, the more air, water and food they need. You can modify your ship with structrues that increase air, water or food production.
	ExecutiveOfficer (Normal): We have plenty of air and water for this crew size, but our food stocks are running low. Please build two food production buildings to increase our food production.
	- Start building 2 more food production buildings.
		[call_node path="EventManager" method="change_objective_label" args="["Build 2 Food building"]" single_use="true"]
		Please click on the ship or the build button, navigate to Food tab, then choose the Vertical Farm.
		The number 2 next to the building name mean it required 2 workers to build it. You will able to build bigger building after recruited more crew members.
	- Skip tutorial.
		[call_node path="EventManager" method="disable_tutorial" single_use="true"]
	Leave ExecutiveOfficer
	[signal arg="end_event"]
	"""
	return event_source_text

func tutorial2_event() -> String:
	var event_source_text = """
	Join ExecutiveOfficer 0
	[call_node path="EventManager" method="change_objective_label" args="["Survive"]" single_use="true"]
	ExecutiveOfficer (Normal): Greetings, captain. Our food production is going smoothly, but we need more crew to make bigger modifications to the ship. We need more crew quarters to increase our crew numbers.
	ExecutiveOfficer (Normal): Please build two more habitation blocks so we can take on more crew.
	- Start building 2 more habitation buildings.
		[call_node path="EventManager" method="change_objective_label" args="["Build 2 Habitation building"]" single_use="true"]
		Leave ExecutiveOfficer
		Similiar to the food production buildings, open the Build menu, navigate to first tab and choose either Hab Block or Dormitory.
	[signal arg="end_event"]
	"""
	return event_source_text

func tutorial3_event() -> String:
	var n_survivor = 2
	var event_source_text = """
	Join ExecutiveOfficer 0
	[call_node path="EventManager" method="change_objective_label" args="["Survive"]" single_use="true"]
	ExecutiveOfficer (Normal): Greetings, captain. We have picked up a distress signal from a lifeboat. The lifeboat has {n_survivor} people on board and is running low on oxygen. The distress signal says they'll join the crew of any ship who saves them.
	ExecutiveOfficer (Normal): We now have the accommodation facilities to take on extra crew. There are no other ships in the area. We should help and accept their offer to join us, as more crew means we can make more modifications to our ship.
	- Contact the lifeboat and welcome them into the crew.
		[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "{n_survivor}"]" single_use="true"]
		You recruited {n_survivor} people.
		ExecutiveOfficer (Normal): Good work, Captain. We now have more crew, but more crew means we need to produce more oxygen, water and food. From now on, it's important that we balance resource production with each increase in the number of crew. We have limited resources and limited space. Choose wisely!
		ExecutiveOfficer (Normal): Also, Captain, take note that you can ONLY take in the survivors if they are equal or less than available housing. If not enough housing, we can't take anyone at all. For example, if you have 5 survivors and 4 available housing, we will unable to recruit anyone, not 4 of them.
		ExecutiveOfficer (Normal): Therefore, it's alway a good idea to build some extra habitant building to be safe.
		[call_node path="EventManager" method="change_objective_label" args="["Survive"]" single_use="true"]
		Leave ExecutiveOfficer
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"n_survivor"=n_survivor})
	return event_source_text

func disabled_tutorial_event():
	var n_survivor = 2
	var event_source_text = """
	Join ExecutiveOfficer 0
	[call_node path="EventManager" method="change_objective_label" args="["Survive"]" single_use="true"]
	ExecutiveOfficer (Normal): Greetings, captain. We have picked up a distress signal from a lifeboat. The lifeboat has {n_survivor} people on board and is running low on oxygen. The distress signal says they'll join the crew of any ship who saves them.
	- Contact the lifeboat and welcome them into the crew.
		[call_node path="ResourceManager" method="change_resource_from_event" args="["population", "{n_survivor}"]" single_use="true"]
		You recruited {n_survivor} people.
		[call_node path="EventManager" method="change_objective_label" args="["Survive"]" single_use="true"]
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
		You get {n_amount} air
		[call_node path="ResourceManager" method="change_resource_from_event" args="["air", "{n_amount}"]" single_use="true"]
	[signal arg="end_event"]
	"""
	event_source_text = event_source_text.format({"n_amount"=n_amount})
	return event_source_text


