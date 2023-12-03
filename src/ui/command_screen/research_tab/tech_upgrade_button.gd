@tool
extends Control
class_name TechUpgradeButton

@export var upgrade_name: String
@export_multiline var upgrade_description: String
@export var upgrade_id: EnumAutoload.UpgradeId = EnumAutoload.UpgradeId.NONE
@export var upgrade_sprite: Texture2D
@export var cost: ResourceCost

@export var connection_lines: Array[Line2D] = []
@export var require_one_of_these_upgrades: Array[TechUpgradeButton] = [] # Must have one of these, not all of these
@export var conflict_one_of_these_upgrades: Array[TechUpgradeButton] = [] # Must NOT have one of these

@onready var texture_rect: TextureRect = $TextureRect
@onready var border: TextureRect = $Border

var research_tab: ResearchTab = null
var activated = false
var disabled = false

func _ready() -> void:
	if upgrade_sprite:
		texture_rect.texture = upgrade_sprite
	if not Engine.is_editor_hint():
		update_status()
		research_tab = get_parent().get_parent().get_parent().get_parent()


func _on_button_pressed() -> void:
	research_tab.select_an_upgrade(self)


func update_status():
	if disabled:
		activated = false
		texture_rect.self_modulate = Color(0.2, 0.2, 0.2)
		border.visible = true
		border.self_modulate = Color(1, 0.1, 0.1)
		for line in connection_lines:
			line.default_color = Color(0.2, 0.2, 0.2)
		return

	if upgrade_id in ResourceManager.current_upgrades:
		activated = true
		texture_rect.self_modulate = Color(1, 1, 1)
		border.visible = true
		for line in connection_lines:
			line.default_color = Color(1, 1, 1)
	else:
		activated = false
		texture_rect.self_modulate = Color(0.2, 0.2, 0.2)
		border.visible = false
		for line in connection_lines:
			line.default_color = Color(0.2, 0.2, 0.2)
