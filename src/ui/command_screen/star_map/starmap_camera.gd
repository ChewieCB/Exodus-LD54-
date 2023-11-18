extends Camera2D

const MIN_ZOOM: float = 4.0
const MAX_ZOOM: float = 16.0
const ZOOM_INCREMENT: float = 0.1
const ZOOM_RATE: float = 16.0

var _target_zoom: float = 8.0


func _physics_process(delta):
	zoom = lerp(
		zoom, _target_zoom * Vector2.ONE,
		ZOOM_RATE * delta 
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			position -= event.relative * zoom * 0.035
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_in()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_out()


func zoom_out() -> void:
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)


func zoom_in() -> void:
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)


