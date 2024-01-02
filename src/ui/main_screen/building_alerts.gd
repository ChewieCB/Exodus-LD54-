extends Control

@onready var alert_container = $VBoxContainer
@onready var resource_low_1_sfx = preload("res://assets/audio/sfx/Resource_Low_1.mp3")
@onready var resource_low_2_sfx = preload("res://assets/audio/sfx/Resource_Low_2.mp3")
@onready var alert_scene: PackedScene

@export var lifetime: float = 1.6


func _ready() -> void:
    ResourceManager.construction_cancelled_lack_of_workers.connect(add_building_alert)


func add_building_alert(building_name: String) -> void:
    # Create an alert
    var new_alert = alert_scene.instantiate()
    var text = "{0} failed\ndue to lack of workers.".format([building_name])
    
    # Add it to the container
    alert_container.add_child(new_alert)
    new_alert.visible = false
    new_alert.alert_text = text
    new_alert.type = EnumAutoload.AlertType.WORKER
    
    # Move it to the top so more recent events show at the top
    alert_container.move_child(new_alert, 0)
    new_alert.visible = true
    new_alert.anim_player.play("alert_in")
    await new_alert.anim_player.animation_finished
    
    # Delete it after a time period
    await get_tree().create_timer(lifetime).timeout
    new_alert.anim_player.play("alert_out")
    await new_alert.anim_player.animation_finished
    new_alert.queue_free()

