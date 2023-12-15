@tool
extends Control

@onready var label = $VBoxContainer/MarginContainer/Label
@onready var progress_bar = $VBoxContainer/MarginContainer2/ProgressBar

@export var label_text: String = ""
@export var bar_min: int = 0
@export var bar_max: int = 100

var gradient: Gradient
var style_box: StyleBoxFlat
var direction_flip: bool = false
var cached_color: Color

func _ready():
	label.text = label_text
	progress_bar.min_value = bar_min
	progress_bar.max_value = bar_max
	
	style_box = StyleBoxFlat.new()
	progress_bar.add_theme_stylebox_override("fill", style_box)
	
	# DEBUG - random start value
	progress_bar.value = randi_range(bar_min, bar_max)
	progress_bar.max_value = bar_max


func _process(delta):
	# DEBUG - animate the bars
#	if progress_bar.value == bar_max or progress_bar.value == bar_min:
#		direction_flip = !direction_flip
#	if direction_flip:
#		progress_bar.value -= 1
#	else:
#		progress_bar.value += 1
	
	# Update the bar colour based on its current value
	var colors = _map_value_to_colour(progress_bar.value)
	var current_color = colors[0]
	var next_color = colors[1]
	cached_color = current_color.lerp(next_color, delta)
	style_box.bg_color = cached_color


func _map_value_to_colour(value: float) -> Array[Color]:
	var mapped_offset = remap(progress_bar.value, bar_min, bar_max, 0.0, 1.0)
	var _current_color
	var _next_color
	
	var color_step = (bar_max - bar_min) / 4
	
	if not cached_color:
		if progress_bar.value < bar_min + color_step:
			_current_color = Color.RED
		elif progress_bar.value >= bar_min + color_step and \
		progress_bar.value < bar_max - color_step:
			_current_color = Color.YELLOW
		elif progress_bar.value >= bar_max - color_step:
			_current_color = Color.GREEN
	else:
		_current_color = cached_color
	
	if mapped_offset < 0.25:
		_next_color = Color.RED
	elif mapped_offset >= 0.25 and mapped_offset < 0.75:
		_next_color = Color.YELLOW
	elif mapped_offset >= 0.75:
		_next_color = Color.GREEN
	
	return [_current_color, _next_color]
