extends Control


func _ready():
	ScreenTransitionManager.fade_in(0.4)
	await ScreenTransitionManager.transitioned
	$AnimationPlayer.play("splash")
	await $AnimationPlayer.animation_finished
	ScreenTransitionManager.fade_out(0.7, 0.5)
	await ScreenTransitionManager.transitioned
	get_tree().change_scene_to_file("res://src/ui/menus/main/MainMenu.tscn")
