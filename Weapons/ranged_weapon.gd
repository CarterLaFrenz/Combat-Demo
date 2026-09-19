extends Node2D

signal attack_started(push_direction: Vector2, push_speed: float, move_multiplier: float)
signal attack_finished

@onready var anim = $AnimationPlayer
@onready var cooldown_timer = $CooldownTimer

var is_attacking = false
@onready var projectile_scene = preload("res://Weapons/Projectile.tscn")
var combo_window_open = false
var combo_queued = false
var combo_chain = ["recoil", "recoil_2", "recoil_3"]
var combo_index = 0
var combo_buffered = false
var damage_chain = [15, 20, 30]
var speed_chain = [600, 700, 900]
var knockback_chain = [150, 150, 300]
var scale_chain = [Vector2(1, 1), Vector2(1, 1), Vector2(1.5, 1.5)]


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
	combo_index = 0
	combo_window_open = false
	combo_queued = false
	combo_buffered = false

	attack_started.emit(Vector2.ZERO, 0.0, 0.8)
	spawn_projectile()
	anim.play(combo_chain[combo_index])

func start_attack_continuation():
	combo_window_open = false
	combo_queued = false
	combo_buffered = false

	attack_started.emit(Vector2.ZERO, 0.0, 0.8)
	spawn_projectile()
	anim.play(combo_chain[combo_index])

func spawn_projectile():
	var bolt = projectile_scene.instantiate()
	bolt.global_position = global_position
	bolt.rotation = get_parent().global_rotation
	bolt.damage = damage_chain[combo_index]
	bolt.speed = speed_chain[combo_index]
	bolt.knockback_force = knockback_chain[combo_index]
	bolt.scale = scale_chain[combo_index]
	get_tree().current_scene.add_child(bolt)

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

func _on_cooldown_timer_timeout():
	is_attacking = false
	combo_index = 0
	attack_finished.emit()
