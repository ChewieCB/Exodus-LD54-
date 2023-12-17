extends HBarUI


func _ready():
	super()
	ResourceManager.morale_changed.connect(_update_progress)
	ResourceManager.morale_effect_applied.connect(_update_morale_details)
	ResourceManager.morale_effect_removed.connect(_update_morale_details)
	TickManager.tick.connect(_update_morale_effect_counters)
	_update_morale_effect_counters()


func _update_progress(value):
	progress_bar.value = value


func _update_morale_details(_updated_effect):
	# TODO - make this more optimal than destroy/rebuild every update
	# Clear morale details
	for _node in details_modifiers.get_children():
		details_modifiers.remove_child(_node)
		_node.queue_free()
	
	# Add new detail for each entry in the effect queue
	var morale_effects = ResourceManager.morale_effect_queue
	for _effect in morale_effects:
		var _detail_instance = detail_container.instantiate()
		var modifier = _effect.morale_modifier_value
		var _mod_str = "+" + str(modifier)
		if modifier < 0:
			_mod_str = _mod_str.erase(0)
		var effect_text = "%s: %s (%s)" % [_effect._name, _mod_str, _effect.ticks_left]
		_detail_instance.get_child(0).text = effect_text
		#
		details_modifiers.add_child(_detail_instance)


func _update_morale_effect_counters():
	if details_modifiers.get_children():
		var morale_effects = ResourceManager.morale_effect_queue
		for idx in range(morale_effects.size()):
			var _effect = morale_effects[idx]
			var modifier = _effect.morale_modifier_value
			var _mod_str = "+" + str(modifier)
			if modifier < 0:
				_mod_str = _mod_str.erase(0)
				
			var effect_text: String
			if _effect.type == MoraleEffect.TYPES.TemporaryMoraleEffect:
				effect_text = "%s: %s (%s)" % [_effect._name, _mod_str, _effect.ticks_left]
			else:
				effect_text = "%s: %s" % [_effect._name, _mod_str]
			details_modifiers.get_child(idx).get_child(0).text = effect_text


func _on_mouse_entered():
	var morale_mod_value = ResourceManager.current_morale_modifier
	var morale_mod = "+" + str(morale_mod_value)
	if morale_mod_value <= 0:
		morale_mod = morale_mod.erase(0)
	details_base.text = "Base: %s" % [ResourceManager.habitability]
	details_total.text = "Total: %s" % [ResourceManager.morale_amount]
	show_details()


func _on_mouse_exited():
	hide_details()
