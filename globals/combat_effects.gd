extends Node

func hitlag(duration: float):
	get_tree().paused = true
	await get_tree().create_timer(duration, true, false, true).timeout
	get_tree().paused = false

func screen_shake(intensity: float, duration: float):
	var camera = get_tree().get_first_node_in_group("camera")
	if camera:
		camera.start_shake(intensity, duration)
