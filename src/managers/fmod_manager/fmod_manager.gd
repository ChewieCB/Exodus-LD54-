extends Node

@export var event: EventAsset
@export var bus_asset: BusAsset
var instance: EventInstance = null
var bus: Bus = null

func _ready() -> void:
    instance = FMODRuntime.create_instance(event)
    instance.start()
    bus = FMODStudioModule.get_studio_system().get_bus(bus_asset.path)

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_PREDELETE:
            on_predelete()

func on_predelete() -> void:
    if instance == null:
        return
    instance.stop(FMODStudioModule.FMOD_STUDIO_STOP_ALLOWFADEOUT)

func update_dynamic_music(new_ratio: float):
    if instance == null:
        return
    instance.set_parameter_by_name("Food-Water-Air", new_ratio, false)

func change_music_volume(volume: float):
    if bus == null:
        return
    bus.set_volume(volume)
