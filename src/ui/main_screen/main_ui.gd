extends Control

@export var ship_sprite: Sprite2D
@export var ship_grid: Node2D
@export var camera: Camera2D
@export var far_view_marker: Marker2D
@export var space_background: Sprite2D

@onready var build_show_toggle: MarginContainer = $BuildShowToggle
@onready var build_menu: MarginContainer = $BuildMenu
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var build_menu_open = false

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_build_button_pressed():
	if anim_player.animation_finished:
		var tween = get_tree().create_tween()
		if build_menu_open:
			anim_player.play("hide_build_menu")
			build_menu_open = false
			ship_grid.visible = false
			tween.tween_property(camera, "zoom", Vector2(0.1, 0.1), 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.tween_property(camera, "global_position", far_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
		else:
			anim_player.play("show_build_menu")
			build_menu_open = true
			ship_grid.visible = true
			tween.tween_property(camera, "global_position", ship_sprite.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.tween_property(camera, "zoom", Vector2(0.4, 0.4), 0.5).set_trans(Tween.TRANS_LINEAR)


func _on_play_dialog_pressed():
	# TODO - refactor this with TickManager calls
	ResourceManager.stop_ticks()
	ship_sprite.visible = false
	ship_grid.visible = false
	build_show_toggle.visible = false
	build_menu.visible = false
	space_background.visible = false
	var dialog = Dialogic.start(EventManager.get_random_event())


func _on_dialogic_signal(arg: String):
	match arg:
		"end_event":
			ship_sprite.visible = true
			ship_grid.visible = true
			build_show_toggle.visible = true
			build_menu.visible = true
			space_background.visible = true
			if build_menu_open:
				ship_grid.visible = true
			else:
				ship_grid.visible = false
			# TODO - refactor this with TickManager calls
			ResourceManager.start_ticks()

