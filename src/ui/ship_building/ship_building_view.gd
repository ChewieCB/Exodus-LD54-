extends Node2D


func _ready():
	# Set initial resources
	ResourceManager.housing_amount = 0
	ResourceManager.food_amount = 20
	ResourceManager.water_amount = 300
	ResourceManager.air_amount = 150
	#
	ScreenTransitionManager.fade_in(1.5)
	await ScreenTransitionManager.transitioned

