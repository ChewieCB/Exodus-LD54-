extends Node

@export var event: EventAsset
var instance: EventInstance = null

func _ready() -> void:
    instance = FMODRuntime.create_instance(event)
    instance.start()

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
