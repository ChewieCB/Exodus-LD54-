extends Node2D

@onready var anim_player = $AnimationPlayer


func _ready():
	BuildingManager.not_enough_workers.connect(not_enough_workers_popup)


func _process(delta):
	self.global_position = get_global_mouse_position()


func not_enough_workers_popup():
	if not anim_player.is_playing():
		anim_player.play("show_popup")
