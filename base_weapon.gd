class_name BaseWeapon
extends Node2D

signal attack_started(push_direction: Vector2, push_speed: float, move_multiplier: float)
signal attack_finished

@onready var anim = $AnimationPlayer
@onready var cooldown_timer = $CooldownTimer

# --- Per-weapon data (set these in each weapon scene's Inspector) ---
@export var combo_chain: Array[String] = []
@export var damage_chain: Array[int] = []
@export var knockback_chain: Array[int] = []
@export var push_speed: float = 0.0
@export var push_sign: float = 0.0       # +1 = lunge forward, -1 = push back, 0 = none
@export var move_multiplier: float = 1.0

# --- Combo state ---
var is_attacking = false
var combo_window_open = false
var combo_queued = false
var combo_buffered = false
var combo_index = 0


# TEMPORARY: moves to WeaponManager in the next Phase 0 commit
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
	_play_hit(0)


func _play_hit(index: int):
	combo_index = index
	combo_window_open = false
	combo_queued = false
	combo_buffered = false

	var pivot_direction = Vector2.RIGHT.rotated(get_parent().global_rotation)
	attack_started.emit(pivot_direction * push_sign, push_speed, move_multiplier)

	_on_hit_started(index)
	anim.play(combo_chain[index])


func open_combo_window():
	combo_window_open = true
	if combo_buffered:
		combo_queued = true
		combo_buffered = false


func _on_animation_player_animation_finished(_anim_name):
	if combo_queued and combo_index < combo_chain.size() - 1:
		_play_hit(combo_index + 1)
	else:
		_on_string_ended()
		cooldown_timer.start()


func _on_cooldown_timer_timeout():
	is_attacking = false
	combo_index = 0
	attack_finished.emit()


# TODO: you write this one (see the list)
func cancel_attack():
	if not is_attacking:
		return
	anim.stop()
	cooldown_timer.stop()
	is_attacking = false
	combo_window_open = false
	combo_queued = false
	combo_buffered = false
	combo_index = 0

	_on_string_ended()
	attack_finished.emit()


# --- Hooks: children override these. Empty by default. ---

# Called at the start of every hit in the string.
func _on_hit_started(_index: int) -> void:
	pass

# Called when the string ends (finished or cancelled).
func _on_string_ended() -> void:
	pass
