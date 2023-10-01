extends Node2D


func _ready():
	ResourceManager.connect("game_over", _game_over)
	ScreenTransitionManager.fade_in(0.8)
	await ScreenTransitionManager.transitioned


func _game_over(resource):
	# TODO - show game over UI
	get_tree().paused = true
	var resource_str
	match resource:
		ResourceManager.RESOURCE_TYPE.FOOD:
			resource_str = "food"
		ResourceManager.RESOURCE_TYPE.WATER:
			resource_str = "water"
		ResourceManager.RESOURCE_TYPE.AIR:
			resource_str = "air"
	print("Game over! You ran out of {0}.".format([resource_str]))
	ScreenTransitionManager.fade_out(5.0)
	await ScreenTransitionManager.transitioned
	get_tree().quit()
