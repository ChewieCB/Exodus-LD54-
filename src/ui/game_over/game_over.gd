extends Control

@onready var flavour_text = $MarginContainer/VBoxContainer/GameOverFlavour
@onready var anim_player = $AnimationPlayer

var button_click_sfx = preload("res://assets/audio/sfx/ui_click_1.mp3")


func _ready():
	ResourceManager.connect("game_over", _game_over)
	get_tree().paused = false
	TickManager.start_ticks()


func _game_over(resource):
	print("GameOver")
	get_tree().paused = true
	TickManager.stop_ticks()
	get_parent().anim_player.play("hide_build_menu")
	anim_player.play("game_over")
	var resource_str
	match resource:
		ResourceManager.RESOURCE_TYPE.FOOD:
			resource_str = "food"
		ResourceManager.RESOURCE_TYPE.WATER:
			resource_str = "water"
		ResourceManager.RESOURCE_TYPE.AIR:
			resource_str = "air"
	flavour_text.text = "You ran out of {0}.".format([resource_str])


func _on_restart_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	ScreenTransitionManager.fade_out(0.7)
	await ScreenTransitionManager.transitioned
	await get_tree().create_timer(0.6).timeout
	TickManager._set_tick_rate(TickManager.SLOW_TICK_SPEED)
	get_tree().reload_current_scene()


func _on_quit_button_pressed():
	SoundManager.play_sound(button_click_sfx, "UI")
	ScreenTransitionManager.fade_out(1.5)
	await ScreenTransitionManager.transitioned
	get_tree().quit()
