extends OptionButton






func _on_item_selected(index):
	if index == 0:
		EventManager.play_specific_event("families_seeking_passage")
