@tool
extends Control
class_name TechUpgradeButton

# Also work as dataholder for upgrade since I don't feel the need to a separate resource file

@export var upgrade_name: String
@export_multiline var upgrade_description: String
@export var upgrade_id: EnumAutoload.UpgradeId = EnumAutoload.UpgradeId.NONE
@export var upgrade_sprite: Texture2D
@export var cost: ResourceData
@export var research_time: int = 1
var research_time_left: int
var is_researching = false

@export var connection_lines: Array[Line2D] = []
@export var require_one_of_these_upgrades: Array[TechUpgradeButton] = [] # Must have one of these, not all of these
@export var conflict_one_of_these_upgrades: Array[TechUpgradeButton] = [] # Must NOT have one of these

@onready var texture_rect: TextureRect = $TextureRect
@onready var border: TextureRect = $Border
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var build_timer_ui = $BuildTimerUI

var research_tab: ResearchTab = null
var activated = false
@export var disabled = false

func _ready() -> void:
	build_timer_ui.visible = false
	research_time_left = research_time
	if upgrade_sprite:
		texture_rect.texture = upgrade_sprite
		if disabled:
			texture_rect.self_modulate = Color(0.2, 0.2, 0.2)
			border.visible = true
			border.self_modulate = Color.RED
			for line in connection_lines:
				line.default_color = Color(0.2, 0.2, 0.2)
	if not Engine.is_editor_hint():
		update_status()
		research_tab = get_parent().get_parent().get_parent().get_parent()


func _on_button_pressed() -> void:
	research_tab.select_an_upgrade(self)


func update_status():
	if disabled:
		activated = false
		is_researching = false
		texture_rect.self_modulate = Color(0.2, 0.2, 0.2)
		border.visible = true
		border.self_modulate = Color.RED
		anim_player.stop()
		build_timer_ui.visible = false
		for line in connection_lines:
			line.default_color = Color(0.2, 0.2, 0.2)
		return

	if upgrade_id in ResourceManager.current_upgrades:
		activated = true
		is_researching = false
		texture_rect.self_modulate = Color(1, 1, 1)
		border.visible = true
		border.self_modulate = Color.GREEN
		anim_player.stop()
		build_timer_ui.visible = false
		for line in connection_lines:
			line.default_color = Color(1, 1, 1)
	else:
		activated = false
		texture_rect.self_modulate = Color(0.2, 0.2, 0.2)
		border.visible = false
		for line in connection_lines:
			line.default_color = Color(0.2, 0.2, 0.2)

	if check_for_previous_upgrade():
		texture_rect.self_modulate = Color(1, 1, 1)

	if is_researching:
		build_timer_ui.set_text(str(research_time_left))
		build_timer_ui.visible = true


func check_for_previous_upgrade():
	var have_previous_upgrade = true
	if len(require_one_of_these_upgrades) > 0:
		have_previous_upgrade = false
		for upgr in require_one_of_these_upgrades:
			if upgr.activated:
				have_previous_upgrade = true
	return have_previous_upgrade


func start_research():
	is_researching = true
	build_timer_ui.set_color(Color.GREEN)
	anim_player.play("highlight")

func pause_research():
	# is_researching should still be true
	build_timer_ui.set_color(Color.YELLOW)
	anim_player.stop()
