@tool
extends Control
class_name TechUpgradeButton

@export var upgrade_name: String
@export_multiline var upgrade_description: String
@export var upgrade_id: EnumAutoload.UpgradeId
@export var upgrade_sprite: Texture2D
@export var connection_lines: Array[Line2D]

@onready var texture_rect: TextureRect = $TextureRect
@onready var border: TextureRect = $Border

var command_screen: ResearchTab = null
var activated = false

func _ready() -> void:
	if upgrade_sprite:
		texture_rect.texture = upgrade_sprite
	if not Engine.is_editor_hint():
		update_status()
		command_screen = get_parent().get_parent()


func _on_button_pressed() -> void:
	var upgrade_desc_label: RichTextLabel = get_parent().get_node("UpgradeDescription")
	upgrade_desc_label.text = "[u]{upgrade_name}[/u]\n[font_size=12]{upgrade_description}[/font_size]".format(
		{"upgrade_name": upgrade_name, "upgrade_description": upgrade_description})
	command_screen.chose_an_upgrade(upgrade_id)

func update_status():
	if upgrade_id in ResourceManager.current_upgrades:
		activated = true
		var button = get_node("Button")
		texture_rect.self_modulate = Color(1, 1, 1)
		border.visible = true
		for line in connection_lines:
			line.default_color = Color(1, 1, 1)
	else:
		activated = true
		texture_rect.self_modulate = Color(0.2, 0.2, 0.2)
		border.visible = false
		for line in connection_lines:
			line.default_color = Color(0.2, 0.2, 0.2)
