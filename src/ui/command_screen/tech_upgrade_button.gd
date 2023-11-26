extends Control
class_name TechUpgradeButton

@export var upgrade_name: String
@export_multiline var upgrade_description: String
@export var upgrade_id: int
@export var upgrade_sprite: Texture2D

func _ready() -> void:
	if upgrade_sprite:
		get_node("TextureRect").texture = upgrade_sprite

func _on_button_pressed() -> void:
	var upgrade_desc_label: RichTextLabel = get_parent().get_node("UpgradeDescription")
	upgrade_desc_label.text = "[u]{upgrade_name}[/u]\n[font_size=12]{upgrade_description}[/font_size]".format(
		{"upgrade_name": upgrade_name, "upgrade_description": upgrade_description})