extends Label
class_name OfficerLabel

@export var portrait_sprite: Texture2D
@export var officer: EnumAutoload.Officer
@export_multiline var description: String

@export var portrait_texturerect: TextureRect
@export var desc_label: Label


func _on_mouse_exited() -> void:
	portrait_texturerect.visible = false
	desc_label.visible = false

func _on_mouse_entered() -> void:
	portrait_texturerect.texture = portrait_sprite
	portrait_texturerect.visible = true
	desc_label.text = description
	desc_label.visible = true
