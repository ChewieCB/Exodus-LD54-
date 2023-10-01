extends Node2D


func _ready():
	ScreenTransitionManager.fade_in(0.8)
	await ScreenTransitionManager.transitioned


func _input(event:InputEvent):
# check if a dialog is already running
	if Dialogic.current_timeline != null:
		return
	
	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		Dialogic.start('testDialog0')
		get_viewport().set_input_as_handled()


func _on_menu_button_pressed():
	ScreenTransitionManager.fade_out(0.8)
	await ScreenTransitionManager.transitioned
	get_tree().change_scene_to_file("res://src/ui/menus/main/MainMenu.tscn")
