extends MarginContainer


func start_random_event():
	var dialog = Dialogic.start(EventManager.get_random_event())
