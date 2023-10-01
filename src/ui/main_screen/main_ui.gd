extends Control

@export var ship_sprite: Sprite2D
@export var ship_grid: Node2D
@export var camera: Camera2D
@export var mid_view_marker: Marker2D
@export var far_view_marker: Marker2D
@export var space_background: Sprite2D
@export var event_image: Sprite2D

@onready var build_show_toggle: MarginContainer = $BuildShowToggle
@onready var build_menu: MarginContainer = $BuildMenu
@onready var event_container = $EventContainer
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
			tween.parallel().tween_property(camera, "zoom", Vector2(0.4, 0.4), 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(camera, "global_position", mid_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
		else:
			anim_player.play("show_build_menu")
			build_menu_open = true
			ship_grid.visible = true
			tween.parallel().tween_property(camera, "global_position", ship_sprite.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(camera, "zoom", Vector2(0.6, 0.6), 0.5).set_trans(Tween.TRANS_LINEAR)


func _on_play_dialog_pressed():
	TickManager.stop_ticks()
	
	var tween = get_tree().create_tween()
	if build_menu_open:
		anim_player.play("hide_build_menu")
		build_menu_open = false
	tween.parallel().tween_property(camera, "zoom", Vector2(0.15, 0.15), 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(camera, "global_position", far_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
	
#	ship_sprite.visible = false
	ship_grid.visible = false
	build_show_toggle.visible = false
	build_menu.visible = false
#	space_background.visible = false

	tween.tween_property(event_image, "modulate:a", 1, 1.0).set_trans(Tween.TRANS_LINEAR)
	event_container.start_random_event()


func _on_dialogic_signal(arg: String):
	match arg:
		"end_event":
			var tween = get_tree().create_tween()
			tween.tween_property(event_image, "modulate:a", 0, 1.0).set_trans(Tween.TRANS_LINEAR)
#			await tween.finished
			
			tween.parallel().tween_property(camera, "zoom", Vector2(0.4, 0.4), 0.5).set_trans(Tween.TRANS_LINEAR)
			tween.parallel().tween_property(camera, "global_position", mid_view_marker.global_position, 0.5).set_trans(Tween.TRANS_LINEAR)
			
			build_show_toggle.visible = true
			build_menu.visible = true
			
			TickManager.start_ticks()
