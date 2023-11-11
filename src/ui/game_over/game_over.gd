extends Control

@onready var flavour_text = $MarginContainer/VBoxContainer/GameOverFlavour
@onready var anim_player = $AnimationPlayer
@onready var game_over_label = $MarginContainer/VBoxContainer/GameOver

func _ready():
	ResourceManager.connect("game_over", _game_over)
	EventManager.connect("victory", _victory)

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

	if resource == ResourceManager.RESOURCE_TYPE.POPULATION:
		flavour_text.text = "All of your crew died."


func _victory():
	print("Victory")
	get_tree().paused = true
	TickManager.stop_ticks()
	get_parent().anim_player.play("hide_build_menu")
	anim_player.play("game_over")
	var resource_str
	game_over_label.text = "Victory"
	flavour_text.text = "You survived. Congratulations"


func _on_restart_button_pressed():
	SoundManager.play_button_click_sfx()
	ScreenTransitionManager.fade_out(0.7)
	await ScreenTransitionManager.transitioned
	await get_tree().create_timer(0.6).timeout

	TickManager.reset_state()
	ResourceManager.reset_state()
	EventManager.reset_state()
	BuildingManager.reset_state()

	get_tree().reload_current_scene()


func _on_quit_button_pressed():
	SoundManager.play_button_click_sfx()
	ScreenTransitionManager.fade_out(1.5)
	await ScreenTransitionManager.transitioned
	get_tree().quit()
