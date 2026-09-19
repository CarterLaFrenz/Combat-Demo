extends Area2D

var speed = 600
var max_distance = 800
var distance_traveled = 0
var damage = 15
var knockback_force = 150

func _physics_process(delta):
	var movement = transform.x * speed * delta
	position += movement
	distance_traveled += movement.length()

	if distance_traveled >= max_distance:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy_hurtbox"):
		var knockback_dir = (area.global_position - global_position).normalized()
		area.get_parent().take_damage(damage, knockback_dir, knockback_force)
		CombatEffects.hitlag(0.03)
		CombatEffects.screen_shake(3.0, 0.08)
		queue_free()
