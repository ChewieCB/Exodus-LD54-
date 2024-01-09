extends Camera2D

const MIN_ZOOM: float = 2.0
const MAX_ZOOM: float = 16.0
const ZOOM_INCREMENT: float = 0.1
const ZOOM_RATE: float = 16.0
var _target_zoom: float = 8.0

var current_target: Node
var ship_node: Node

const PAN_RETURN_RATE: float = 2.5
var pan_wait: float = 1.6
var is_pan_returning: bool = false

var negation_zone_camera_limit_buffer: int = 32
@onready var negation_zone_radius = get_parent().negation_zone_radius
@onready var pan_wait_timer = $PanWaitTimer


func _ready():
	is_pan_returning = true


func _physics_process(delta):
	zoom = lerp(
		zoom, _target_zoom * Vector2.ONE,
		ZOOM_RATE * delta 
	)
	var ship_sprite = get_parent().get_node("ShipTracker/Sprite2D")
	var new_sprite_scale = 0.008 * remap(zoom.x, MIN_ZOOM, MAX_ZOOM, 2, 1)
	ship_sprite.scale = Vector2(new_sprite_scale, new_sprite_scale)
	if is_pan_returning:
		if self.global_position != current_target.global_position:
			# We want to pan faster the further away from the ship we are
			var distance_from_target = global_position.distance_to(
				current_target.global_position
			)
			var pan_distance_multiplier = remap(distance_from_target, 0, 600, 1, 2)
			global_position = lerp(
				global_position, 
				current_target.global_position,
				PAN_RETURN_RATE * pan_distance_multiplier * delta
			)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			position -= event.relative / zoom * 0.35
			# Clamp the camera position so we can't go past the negation zone
			var center = get_screen_center_position()
			var viewport_rect = get_viewport_rect()
			var left_edge = center.x - viewport_rect.size.x
			var right_edge = center.x + viewport_rect.size.x
			var top_edge = center.y + viewport_rect.size.y
			var bottom_edge = center.y - viewport_rect.size.y
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_in()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_out()
			pan_wait_timer.stop()
			is_pan_returning = false
		elif event.is_released():
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				pan_wait_timer.start(pan_wait)
				await pan_wait_timer.timeout
				is_pan_returning = true


func zoom_out() -> void:
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)


func zoom_in() -> void:
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)


func focus_on_node(node: Node, time_to_release: float = 5.0) -> void:
	current_target = node
	pan_wait_timer.stop()
	is_pan_returning = true
	if time_to_release > 0:
		await get_tree().create_timer(time_to_release).timeout
		release_focus()


func release_focus() -> void:
	if ship_node:
		current_target = ship_node 
	pan_wait_timer.stop()
	is_pan_returning = true

