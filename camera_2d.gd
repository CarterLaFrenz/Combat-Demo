extends Camera2D

var shake_intensity = 0.0
var shake_duration = 0.0
var shake_timer = 0.0

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta
		var decay = shake_timer / shake_duration
		offset = Vector2(
			randf_range(-shake_intensity, shake_intensity) * decay,
			randf_range(-shake_intensity, shake_intensity) * decay
		)
	else:
		offset = Vector2.ZERO

func start_shake(intensity: float, duration: float):
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
