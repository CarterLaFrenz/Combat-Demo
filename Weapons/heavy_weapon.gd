extends Node2D

signal attack_started(push_direction: Vector2, push_speed: float, move_multiplier: float)
signal attack_finished

@onready var anim = $AnimationPlayer
@onready var hitbox = $HitboxArea
@onready var cooldown_timer = $CooldownTimer

var is_attacking = false
var lunge_speed = 250
var combo_window_open = false
var combo_queued = false
var combo_buffered = false
var combo_chain = ["sweep", "overhead", "spin"]
var damage_chain = [40, 50, 65]
var knockback_chain = [300, 400, 500]
var combo_index = 0

@export var damage = 40
var hit_enemies = []

func _ready():
	hitbox.monitoring = false
	hitbox.monitorable = false

func _input(event):
	if event.is_action_pressed("attack") and not is_attacking and visible:
		start_attack()
	elif event.is_action_pressed("attack") and is_attacking:
		if combo_window_open:
			combo_queued = true
		else:
			combo_buffered = true

func start_attack():
	is_attacking = true
	hit_enemies.clear()
	combo_index = 0
	combo_window_open = false
	combo_queued = false
	combo_buffered = false

	var pivot_direction = Vector2.RIGHT.rotated(get_parent().global_rotation)
	attack_started.emit(pivot_direction, lunge_speed, 0.2)

	anim.play(combo_chain[combo_index])

func start_attack_continuation():
	hit_enemies.clear()
	combo_window_open = false
	combo_queued = false
	combo_buffered = false

	var pivot_direction = Vector2.RIGHT.rotated(get_parent().global_rotation)
	attack_started.emit(pivot_direction, lunge_speed, 0.2)

	anim.play(combo_chain[combo_index])

func open_combo_window():
	combo_window_open = true
	if combo_buffered:
		combo_queued = true
		combo_buffered = false

func _on_animation_player_animation_finished(_anim_name):
	if combo_queued and combo_index < combo_chain.size() - 1:
		combo_index += 1
		start_attack_continuation()
	else:
		cooldown_timer.start()
		disable_hitbox()

func _on_cooldown_timer_timeout():
	is_attacking = false
	combo_index = 0
	hit_enemies.clear()
	attack_finished.emit()

func _on_hitbox_area_area_entered(area):
	if area.is_in_group("enemy_hurtbox") and area not in hit_enemies:
		hit_enemies.append(area)
		var player = get_tree().get_first_node_in_group("player")
		var knockback_dir = (area.global_position - player.global_position).normalized()
		area.get_parent().take_damage(damage_chain[combo_index], knockback_dir, knockback_chain[combo_index])
		CombatEffects.hitlag(0.08)
		CombatEffects.screen_shake(8.0, 0.15)

func enable_hitbox():
	hitbox.monitoring = true
	hitbox.monitorable = true

func disable_hitbox():
	hitbox.monitoring = false
	hitbox.monitorable = false
