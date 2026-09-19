extends CharacterBody2D
@onready var sprite = $Sprite2D
@onready var weapon_pivot = $WeaponPivot
@onready var health_bar = $"../CanvasLayer/HealthBarFill"
@onready var invincibility_timer = $InvincibilityTimer
@onready var hurtbox = $HurtboxArea

@export var max_health = 100
@export var speed = 250
@export var accel_weight = 0.2
@export var decel_weight = 0.15

var is_attacking = false
var attack_velocity = Vector2.ZERO
var attack_move_multiplier = 1.0

var health: int
var is_invincible = false
var can_act = false

signal player_died


func _ready():
	health = max_health

func _physics_process(delta: float) -> void:
	if not can_act:
		return
		
	if not is_invincible:
		for area in hurtbox.get_overlapping_areas():
			if area.is_in_group("enemy_hitbox"):
				take_damage(area.get_parent().enemy_data.contact_damage)
				break
	
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()

	if is_attacking and attack_velocity != Vector2.ZERO:
		self.velocity = attack_velocity
		attack_velocity = attack_velocity.move_toward(Vector2.ZERO, delta * 500)
	else:
		var current_speed = speed * (attack_move_multiplier if is_attacking else 1.0)
		var target = direction * current_speed
		if direction != Vector2.ZERO:
			self.velocity = self.velocity.lerp(target, accel_weight)
		else:
			self.velocity = self.velocity.lerp(Vector2.ZERO, decel_weight)

	move_and_slide()

	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false

func _process(delta: float) -> void:
	if not can_act:
		return
	var mouse_pos = get_global_mouse_position()
	weapon_pivot.look_at(mouse_pos)

	if mouse_pos.x < global_position.x:
		weapon_pivot.scale.y = -1
	else:
		weapon_pivot.scale.y = 1

func on_attack_started(push_direction: Vector2, push_speed: float, move_multiplier: float):
	is_attacking = true
	attack_velocity = push_direction * push_speed
	attack_move_multiplier = move_multiplier
	is_invincible = true

func on_attack_finished():
	is_attacking = false
	attack_velocity = Vector2.ZERO
	attack_move_multiplier = 1.0
	is_invincible = false

func take_damage(amount: int):
	if is_invincible:
		return
	health -= amount
	is_invincible = true
	invincibility_timer.start()
	flash_sprite()
	update_health_bar()
	if health <= 0:
		died()

func _on_invincibility_timer_timeout():
	is_invincible = false
	sprite.modulate = Color(1, 1, 1, 1)

func flash_sprite():
	var tween = create_tween().set_loops(5)
	tween.tween_property(sprite, "modulate:a", 0.3, 0.05)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.05)

func died():
	player_died.emit()

func _on_hurtbox_area_area_entered(area):
	if area.is_in_group("enemy_hitbox"):
		take_damage(area.get_parent().contact_damage)
		print("OW")

func update_health_bar():
	health_bar.scale.x = float(health) / float(max_health)
