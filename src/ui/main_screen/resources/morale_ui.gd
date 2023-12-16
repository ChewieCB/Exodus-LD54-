extends HBarUI


func _ready():
	super()
	ResourceManager.morale_changed.connect(_update_progress)


func _update_progress(value):
	progress_bar.value = value

