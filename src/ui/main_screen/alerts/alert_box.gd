extends Control

@onready var container = $VBoxContainer
@onready var resource_low_1_sfx = preload("res://assets/audio/sfx/Resource_Low_1.mp3")
@onready var resource_low_2_sfx = preload("res://assets/audio/sfx/Resource_Low_2.mp3")

@export var alert_scene: PackedScene

var food_alert: Alert
var water_alert: Alert
var air_alert: Alert
var morale_alert: Alert
var proximity_alert: Alert

func _ready():
    ResourceManager.construction_cancelled_lack_of_workers.connect(_add_building_alert)
    ResourceManager.starving.connect(_starving)
    ResourceManager.dehydrated.connect(_dehydrated)
    ResourceManager.suffocating.connect(_suffocating)
    ResourceManager.mutiny.connect(_mutiny)
    ResourceManager.research_completed.connect(_research_complete)
    EventManager.proximity_alert.connect(_proximity)

    ResourceManager.game_over.connect(_hide_all)

func _research_complete(research_name: String):
    # Create an alert
    var new_alert: Alert = alert_scene.instantiate()
    container.add_child(new_alert)

    var text = "Research {0} completed.".format([research_name])
    new_alert.visible = false
    new_alert.alert_text = text
    new_alert.type = Alert.TYPE.RESEARCH
    new_alert.has_timer_destroy = true
    
    # Move it to the top so more recent events show at the top
    container.move_child(new_alert, 0)
    new_alert.visible = true
    new_alert.anim_player.play("alert_in")

func _add_building_alert(building_name: String) -> void:
    # Create an alert
    var new_alert: Alert = alert_scene.instantiate()
    container.add_child(new_alert)

    var text = "{0} failed\ndue to lack of workers.".format([building_name])
    new_alert.visible = false
    new_alert.alert_text = text
    new_alert.type = Alert.TYPE.WORKER
    new_alert.has_timer_destroy = true

    # Move it to the top so more recent events show at the top
    container.move_child(new_alert, 0)
    new_alert.visible = true
    new_alert.anim_player.play("alert_in")

func _proximity(ticks_left):
    if not proximity_alert:
        if ticks_left < 6:
            var new_alert = alert_scene.instantiate()
            var text = "Proximity Warning"
            
            # Add it to the container
            container.add_child(new_alert)
            new_alert.visible = false
            new_alert.alert_text = text
            new_alert.type = Alert.TYPE.PROXIMITY
            new_alert.has_countdown = false
            
            # Move it to the top so more recent events show at the top
            container.move_child(new_alert, 0)
            new_alert.visible = true
            new_alert.anim_player.play("alert_in")
            await new_alert.anim_player.animation_finished
            #
            proximity_alert = new_alert
            SoundManager.play_sound(resource_low_1_sfx, "SFX")
    else:
        if ticks_left > 6:
            if is_instance_valid(proximity_alert):
                # Delete it after a time period
                proximity_alert.anim_player.play("alert_out")
                await proximity_alert.anim_player.animation_finished
                proximity_alert.queue_free()

func _starving(ticks_left):
    if ResourceManager.is_starving:
        if not food_alert:
            # Create a food alert with countdown
            var new_alert = alert_scene.instantiate()
            var text = "Days Until Starvation"
            
            # Add it to the container
            container.add_child(new_alert)
            new_alert.visible = false
            new_alert.alert_text = text
            new_alert.type = Alert.TYPE.FOOD
            new_alert.has_countdown = true
            new_alert.countdown_value = ticks_left
            
            # Move it to the top so more recent events show at the top
            container.move_child(new_alert, 0)
            new_alert.visible = true
            new_alert.anim_player.play("alert_in")
            await new_alert.anim_player.animation_finished
            #
            food_alert = new_alert
            SoundManager.play_sound(resource_low_1_sfx, "SFX")
        
        # Update the countdown
        food_alert.countdown_value = ticks_left
    else:
        if is_instance_valid(food_alert):
            food_alert.remove_alert()

func _dehydrated(ticks_left):
    if ResourceManager.is_thirsty:
        if not water_alert:
            # Create a food alert with countdown
            var new_alert = alert_scene.instantiate()
            var text = "Days Until Dehydration"
            
            # Add it to the container
            container.add_child(new_alert)
            new_alert.visible = false
            new_alert.alert_text = text
            new_alert.type = Alert.TYPE.WATER
            new_alert.has_countdown = true
            new_alert.countdown_value = ticks_left
            
            # Move it to the top so more recent events show at the top
            container.move_child(new_alert, 0)
            new_alert.visible = true
            new_alert.anim_player.play("alert_in")
            await new_alert.anim_player.animation_finished
            #
            water_alert = new_alert
            SoundManager.play_sound(resource_low_1_sfx, "SFX")
        
        # Update the countdown
        water_alert.countdown_value = ticks_left
    else:
        if is_instance_valid(water_alert):
            water_alert.remove_alert()

func _suffocating(ticks_left):
    if ResourceManager.is_suffocating:
        if not air_alert:
            # Create a food alert with countdown
            var new_alert = alert_scene.instantiate()
            var text = "Days Until Suffocation"
            
            # Add it to the container
            container.add_child(new_alert)
            new_alert.visible = false
            new_alert.alert_text = text
            new_alert.type = Alert.TYPE.AIR
            new_alert.has_countdown = true
            new_alert.countdown_value = ticks_left
            
            # Move it to the top so more recent events show at the top
            container.move_child(new_alert, 0)
            new_alert.visible = true
            new_alert.anim_player.play("alert_in")
            await new_alert.anim_player.animation_finished
            #
            air_alert = new_alert
            SoundManager.play_sound(resource_low_1_sfx, "SFX")
        
        # Update the countdown
        air_alert.countdown_value = ticks_left
    else:
        if is_instance_valid(air_alert):
            air_alert.remove_alert()

func _mutiny(ticks_left):
    if ResourceManager.is_mutiny:
        if not morale_alert:
            # Create a food alert with countdown
            var new_alert = alert_scene.instantiate()
            var text = "Days Until Mutiny"
            
            # Add it to the container
            container.add_child(new_alert)
            new_alert.visible = false
            new_alert.alert_text = text
            new_alert.type = Alert.TYPE.MORALE
            new_alert.has_countdown = true
            new_alert.countdown_value = ticks_left
            
            # Move it to the top so more recent events show at the top
            container.move_child(new_alert, 0)
            new_alert.visible = true
            new_alert.anim_player.play("alert_in")
            await new_alert.anim_player.animation_finished
            #
            morale_alert = new_alert
            SoundManager.play_sound(resource_low_1_sfx, "SFX")
        
        # Update the countdown
        morale_alert.countdown_value = ticks_left
    else:
        if is_instance_valid(morale_alert):
            morale_alert.remove_alert()

func _hide_all(resource):
    for _alert in [food_alert, water_alert, air_alert, morale_alert]:
        if is_instance_valid(_alert):
            _alert.remove_alert()

