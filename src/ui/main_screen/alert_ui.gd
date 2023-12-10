extends MarginContainer

signal new_alert()
signal hide_alert()

@onready var alert_message = $PanelContainer/VBoxContainer/MarginContainer2/Message
@onready var confirm = $PanelContainer/VBoxContainer/MarginContainer/Button

var message_queue = []


func _ready():
	ResourceManager.resource_low.connect(_resource_low_alert)


func _resource_low_alert(resource):
	var val_1
	var val_2
	match resource:
		EnumAutoload.ResourceType.FOOD:
			val_1 = "is starving!"
			val_2 = "farms"
		EnumAutoload.ResourceType.WATER:
			val_1 = "is dying of thirst!"
			val_2 = "water processing"
		EnumAutoload.ResourceType.AIR:
			val_1 = "is suffocating!"
			val_2 = "air cyclers"
	
	alert_message.text = "The ship {0}!\nBuild more {1}".format([val_1, val_2])
	
	emit_signal("new_alert")


func _on_confirm_pressed():
	emit_signal("hide_alert")
