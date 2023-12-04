extends TabBar
class_name StatusTab

@onready var ship_status_label: Label = $ShipStatusLabel
@onready var ship_upgrade_warning_label: Label = $WarningLabel
@onready var ship_hull_upgrade_button: Button = $UpgradeHullButton

const SHIP_HULL_METAL_COST_PER_LV = 10

func _ready() -> void:
    ResourceManager.upgrade_acquired.connect(apply_upgrade_change)


func apply_upgrade_change():
    if EnumAutoload.UpgradeId.SHIP_INFRA_HULL_UPGRADE_EXPERTISE in ResourceManager.current_upgrades:
        ship_hull_upgrade_button.visible = true
    else:
        ship_hull_upgrade_button.visible = false
    update_ship_status_screen()

func reset_stuff_on_tab() -> void:
    ship_upgrade_warning_label.visible = false

func update_ship_status_screen():
    var upgrade_hull_metal_cost = calculate_ship_hull_upgrade_cost()
    ship_hull_upgrade_button.text = "Improve ship hull\n({cost} Metal)".format({"cost": upgrade_hull_metal_cost})
    ship_status_label.text = "Ship hull Lv. {ship_hull_lv}\nSpeed: ~{ship_speed} LY / day".format(
        {"ship_hull_lv": EventManager.ship_hull_level, "ship_speed": 1})

func calculate_ship_hull_upgrade_cost():
    var cost = EventManager.ship_hull_level * SHIP_HULL_METAL_COST_PER_LV
    if EnumAutoload.UpgradeId.SHIP_INFRA_MODULAR_HULL_PLATES in ResourceManager.current_upgrades:
        cost = ceil(cost * 0.5)
    return cost

func _on_upgrade_hull_button_pressed() -> void:
    SoundManager.play_button_click_sfx()
    var upgrade_hull_metal_cost = calculate_ship_hull_upgrade_cost()
    if ResourceManager.metal_amount >= upgrade_hull_metal_cost:
        ResourceManager.metal_amount -= upgrade_hull_metal_cost
        ship_upgrade_warning_label.visible = false
        EventManager.ship_hull_level += 1
        update_ship_status_screen()
    else:
        ship_upgrade_warning_label.text = "Warning: Not enough resource"
        ship_upgrade_warning_label.visible = true