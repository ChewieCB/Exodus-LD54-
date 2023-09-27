extends Control

@onready var anim_player = $AnimationPlayer


func _ready():
	ScreenTransitionManager.fade_in(0.8)
	await ScreenTransitionManager.transitioned


func _on_settings_button_pressed():
	anim_player.play("main_out")
	anim_player.queue("settings_in")


func _on_back_button_pressed():
	anim_player.queue("settings_out")
	anim_player.queue("main_in")
