extends HBarUI


func _ready():
	super()
	ResourceManager.morale_changed.connect(_update_progress)


func _update_progress(value):
	progress_bar.value = value


func _on_mouse_entered():
	var morale_mod_value = ResourceManager.current_morale_modifier
	var morale_mod = "+" + str(morale_mod_value)
	if morale_mod_value <= 0:
		morale_mod = morale_mod.erase(0)
	details_base.text = "Base: %s" % [ResourceManager.habitability]
	details_modifiers.get_child(0).get_child(0).text = morale_mod
	details_total.text = "Total: %s" % [ResourceManager.morale_amount]
	show_details()


func _on_mouse_exited():
	hide_details()
