extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var label = $Margin/MarginContainer/PanelContainer/MarginContainer/Label


func _ready():
	BuildingManager.not_enough_workers.connect(not_enough_workers_popup)
	BuildingManager.not_enough_resource.connect(not_enough_resource_popup)
	ResourceManager.ui_hover_show.connect(resource_ui_popup_show)
	ResourceManager.ui_hover_hide.connect(resource_ui_popup_hide)


func _process(delta):
	self.global_position = get_global_mouse_position()


func not_enough_workers_popup():
	label.text = "Not enough workers!"
	if anim_player.is_playing() and anim_player.current_animation != "show_popup":
		anim_player.stop()
	anim_player.play("show_popup")

func not_enough_resource_popup():
	label.text = "Not enough resource!"
	if anim_player.is_playing() and anim_player.current_animation != "show_popup":
		anim_player.stop()
	anim_player.play("show_popup")

func resource_ui_popup_show(text: String):
	label.text = text
	if anim_player.is_playing() and anim_player.current_animation != "show_popup_hold":
		anim_player.stop()
	anim_player.play("show_popup_hold")

func resource_ui_popup_hide():
	if anim_player.is_playing() and anim_player.current_animation != "popup_hide":
		anim_player.stop()
	anim_player.play("popup_hide")
