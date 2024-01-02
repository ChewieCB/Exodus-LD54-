# extends Node

# @export var event: EventAsset
# @export var bus_asset: BusAsset

# var stop_time = false

# var instance: EventInstance = null
# var bus: Bus = null

# const MORALE_TRANSITION_DEBUG = false

# func _ready() -> void:
# 	instance = FMODRuntime.create_instance(event)
# 	instance.start()
# 	bus = FMODStudioModule.get_studio_system().get_bus(bus_asset.path)

# func _notification(what: int) -> void:
# 	match what:
# 		NOTIFICATION_PREDELETE:
# 			on_predelete()

# func on_predelete() -> void:
# 	if instance == null:
# 		return
# 	instance.stop(FMODStudioModule.FMOD_STUDIO_STOP_ALLOWFADEOUT)

# func update_dynamic_music(new_ratio: float):
# 	if instance == null:
# 		return
# 	# print("new ratio ", new_ratio)
# 	instance.set_parameter_by_name("Food-Water-Air", new_ratio, false)

# func change_music_volume(volume: float):
# 	if bus == null:
# 		return
# 	bus.set_volume(volume)

# func _on_timer_timeout():
# 	if not MORALE_TRANSITION_DEBUG:
# 		return

# 	var morale = FMODStudioModule.get_studio_system().get_parameter_by_name("Morale").final_value
# 	print("morale ", morale)
# 	if morale == 100:
# 		FMODStudioModule.get_studio_system().set_parameter_by_name("Morale", -100, false)
# 	else:
# 		FMODStudioModule.get_studio_system().set_parameter_by_name("Morale", 100, false)
