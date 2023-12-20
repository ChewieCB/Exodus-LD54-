extends HBarUI


func _ready():
	super()
	ResourceManager.morale_changed.connect(_update_progress)
	ResourceManager.morale_effect_applied.connect(update_morale_details)
	ResourceManager.morale_effect_removed.connect(remove_morale_details)
	TickManager.tick.connect(update_morale_effect_counters)
	
	update_morale_details(ResourceManager.morale_effect_queue)
	update_morale_effect_counters()


func _update_progress(value):
	progress_bar.value = value


func remove_morale_details(details_to_remove: Array):
	for _detail in details_to_remove:
		details_modifiers.remove_child(_detail)
		_detail.queue_free()
		await _detail.tree_exited
	update_morale_details(ResourceManager.morale_effect_queue)


func update_morale_details(updated_effects: Array):
	_cull_freed_containers()
	var existing_detail_containers = details_modifiers.get_children()
	# Get every existing child node of the details_modifiers container,
	# then filter these nodes to return only those that match objects 
	# given in updated_effects input - these are the labels we need to update.
	var _details_to_update = existing_detail_containers.filter(
		func(_detail_container):
			return _detail_container.effect in updated_effects
	)
	for _detail_container in _details_to_update:
		var effect_text = _generate_effect_modifier_string(_detail_container.effect)
		_detail_container.label.text = effect_text
	
	# Check if we have any new MoraleEffects in the updated_effects input.
	var existing_effects = []
	for _detail in existing_detail_containers:
		existing_effects.append(_detail.effect)
	
	var _new_effects = updated_effects.filter(
		func(_effect):
			return _effect not in existing_effects
	)
	# For any new MoraleEffects, create a detail container and update the label.
	for _effect in _new_effects:
		var effect_text = _generate_effect_modifier_string(_effect)
		var _detail_instance = detail_container.instantiate() 
		_detail_instance.text = effect_text
		_detail_instance.effect = _effect
		details_modifiers.add_child(_detail_instance)


func update_morale_effect_counters():
	_cull_freed_containers()
	var existing_detail_containers = details_modifiers.get_children()
	for _detail_container in existing_detail_containers:
		var _effect = _detail_container.effect
#		if _effect:
		var effect_text = _generate_effect_modifier_string(_effect)
		_detail_container.label.text = effect_text


func _cull_freed_containers():
	# Check if we have any freed effects that need cleaning up
	var existing_detail_containers = details_modifiers.get_children()
	for _container in existing_detail_containers:
		if _container.effect == null:
			details_modifiers.remove_child(_container)
			existing_detail_containers.erase(_container)
			_container.queue_free()


func _generate_effect_modifier_string(effect: MoraleEffect) -> String:
	var _mod = effect.morale_modifier_value
	var _mod_str = "+" + str(_mod)
	if _mod < 0:
		_mod_str = _mod_str.erase(0)
	
	var output_text = ""
	if effect.type == MoraleEffect.TYPES.TemporaryMoraleEffect:
		output_text = "%s: %s (%s)" % [effect._name, _mod_str, effect.ticks_left]
	else:
		output_text = "%s: %s" % [effect._name, _mod_str]
	
	return output_text


func _on_mouse_entered():
	var morale_mod_value = ResourceManager.current_morale_modifier
	var morale_mod = "+" + str(morale_mod_value)
	if morale_mod_value <= 0:
		morale_mod = morale_mod.erase(0)
	var housing_mod = ""
	var housing_score = ResourceManager.available_housing * ResourceManager.housing_habitability_impact
	if ResourceManager.available_housing < 0:
		housing_mod = " %s from housing" % [housing_score]
	elif ResourceManager.available_housing > 0:
		housing_mod = " +%s from housing" % [housing_score]
			
	details_base.text = "Base: %s (50%s)" % [ResourceManager.habitability, housing_mod]
	details_total.text = "Total: %s%" % [ResourceManager.morale_amount]
	show_details()


func _on_mouse_exited():
	hide_details()
