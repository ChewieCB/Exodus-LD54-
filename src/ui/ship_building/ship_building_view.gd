extends Node2D


func _ready():
	ScreenTransitionManager.fade_in(0.8)
	await ScreenTransitionManager.transitioned
