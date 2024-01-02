extends Button
class_name OfficerButton

@export var portrait_sprite: Texture2D
@export var officer: EnumAutoload.Officer
@export_multiline var description: String

@export var portrait_texturerect: TextureRect
@export var desc_label: RichTextLabel

func _on_pressed() -> void:
	portrait_texturerect.texture = portrait_sprite
	portrait_texturerect.visible = true
	desc_label.text = description
	desc_label.visible = true
