extends Control

@onready var toggle_build_menu = $BuildShowToggle/Button
@onready var anim_player = $AnimationPlayer

var build_menu_open = false


func _on_build_button_pressed():
	if anim_player.animation_finished:
		if build_menu_open:
			anim_player.play("hide_build_menu")
			build_menu_open = false
		else:
			anim_player.play("show_build_menu")
			build_menu_open = true

