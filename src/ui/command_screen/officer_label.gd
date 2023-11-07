extends Label
class_name OfficerLabel

@export var portrait_sprite: Texture2D
@export var officer: EnumAutoload.Officer

@export var portrait_texturerect: TextureRect


func _on_mouse_exited() -> void:
	portrait_texturerect.visible = false

func _on_mouse_entered() -> void:
	portrait_texturerect.texture = portrait_sprite
	portrait_texturerect.visible = true
