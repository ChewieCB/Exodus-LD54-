extends CanvasLayer

signal transitioned

var tween


func fade(a: float, b: float, duration: float, delay: float = 0) -> void:
	if tween:
		tween.kill()
	$ScreenTransitionManager/Fadeout.modulate = Color(0, 0, 0, a)
	tween = create_tween()
	tween.tween_property(
		$ScreenTransitionManager/Fadeout, "modulate", Color(0, 0, 0, b), duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	if delay:
		tween.tween_interval(delay)
	tween.tween_callback(emit_signal.bind("transitioned"))


func fade_in(duration: float, delay: float = 0) -> void:
	fade(1.0, 0.0, duration, delay)


func fade_out(duration: float, delay: float = 0) -> void:
	fade(0.0, 1.0, duration, delay)

