extends CanvasLayer

signal transitioned

var tween

func fade(a: float, b: float, duration: float, _trans, _ease, _delay: float = 0) -> void:
	if tween:
		tween.kill()
	$ScreenTransitionManager/Fadeout.modulate = Color(0, 0, 0, a)
	tween = create_tween()
	tween.tween_property(
		$ScreenTransitionManager/Fadeout, "modulate", Color(0, 0, 0, b), duration
	).set_trans(_trans).set_ease(_ease)
	if _delay:
		tween.tween_interval(_delay)
	tween.tween_callback(emit_signal.bind("transitioned"))


func fade_in(duration: float, delay: float = 0) -> void:
	fade(1.0, 0.0, duration, Tween.TRANS_QUINT, Tween.EASE_OUT, delay)


func fade_out(duration: float, delay: float = 0) -> void:
	fade(0.0, 1.0, duration, Tween.TRANS_EXPO, Tween.EASE_IN, delay)

