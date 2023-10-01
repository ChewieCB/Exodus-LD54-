extends Control

@export var ship_sprite: Sprite2D
@export var ship_grid: Node2D

@onready var build_show_toggle: MarginContainer = $BuildShowToggle
@onready var build_menu: MarginContainer = $BuildMenu
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var build_menu_open = false

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_build_button_pressed():
	if anim_player.animation_finished:
		if build_menu_open:
			anim_player.play("hide_build_menu")
			build_menu_open = false
		else:
			anim_player.play("show_build_menu")
			build_menu_open = true


func _on_play_dialog_pressed():
	ship_sprite.visible = false
	ship_grid.visible = false
	build_show_toggle.visible = false
	build_menu.visible = false
	var dialog = Dialogic.start(EventManager.get_random_event())


func _on_dialogic_signal(arg: String):
	match arg:
		"end_event":
			ship_sprite.visible = true
			ship_grid.visible = true
			build_show_toggle.visible = true
			build_menu.visible = true


