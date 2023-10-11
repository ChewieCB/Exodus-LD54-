extends OptionButton


func _ready() -> void:
	# Build the debug menu
	var events = EventManager.event_resources
	var planetary_events = []
	var space_events = []
	var debug_events = []
	var self_events = []
	#
	for _event in EventManager.tutorial_events:
		debug_events.append(_event)
	debug_events.append(EventManager.victory_event)
	#
	for _event in events:
		if _event.type == ExodusEvent.EVENT_TYPES.PLANET:
			planetary_events.append(_event)
		elif _event.type == ExodusEvent.EVENT_TYPES.SPACE:
			space_events.append(_event)
		elif _event.type == ExodusEvent.EVENT_TYPES.DEBUG:
			debug_events.append(_event)
		elif _event.type == ExodusEvent.EVENT_TYPES.SELF:
			debug_events.append(_event)
	
	var id_count = 0
	
	# Debug
	if debug_events:
		add_separator("Debug")
		for _event in debug_events:
			add_item(_event.name, id_count)
			id_count += 1
	# Planetary
	if planetary_events:
		add_separator("Planet")
		for _event in planetary_events:
			add_item(_event.name, id_count)
			id_count += 1
	# Space
	if space_events:
		add_separator("Space")
		for _event in space_events:
			add_item(_event.name, id_count)
			id_count += 1
	# Self
	if self_events:
		add_separator("Self")
		for _event in self_events:
			add_item(_event.name, id_count)
			id_count += 1
	# Deselect any options
	select(-1)
