extends HBarUI


func _ready():
	super()
	ResourceManager.morale_changed.connect(_update_progress)


func _update_progress(value):
	progress_bar.value = value


func _on_mouse_entered():
	ResourceManager.emit_signal("morale_detail_show")


func _on_mouse_exited():
	ResourceManager.emit_signal("morale_detail_hide")
