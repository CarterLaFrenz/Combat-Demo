
extends CharacterBody2D

const STATE_IDLE = 0
const STATE_STUNNED = 1
const STATE_DYING = 2

@onready var sprite = $Sprite2D
@export var enemy_data: EnemyData

var health: int
var current_state: int = STATE_IDLE
var knockback_velocity: Vector2 = Vector2.ZERO

signal died


func _ready():
	if enemy_data:
		health = enemy_data.max_health
	else:
		push_warning("No EnemyData assigned to " + name)
		health = 100


func _physics_process(delta: float) -> void:
	if health <= 0 and current_state != STATE_DYING:
		_change_state(STATE_DYING)
		return

	_handle_state(delta)
	move_and_slide()


# --- State handling (children override and call super) ---

func _handle_state(delta: float) -> void:
	match current_state:
		STATE_IDLE:
			_state_idle(delta)
		STATE_STUNNED:
			_state_stunned(delta)
		STATE_DYING:
			pass


func _state_idle(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * enemy_data.move_speed
		sprite.flip_h = velocity.x < 0
	else:
		velocity = Vector2.ZERO


func _state_stunned(delta: float) -> void:
	velocity = knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, delta * 800)
	if knockback_velocity.length() < 10:
		knockback_velocity = Vector2.ZERO
		_change_state(_get_default_state())


# --- State transitions ---

func _change_state(new_state: int) -> void:
	var old_state = current_state
	current_state = new_state
	_exit_state(old_state)
	_enter_state(new_state)


func _enter_state(state: int) -> void:
	match state:
		STATE_DYING:
			died.emit()
			spawn_death_particles()
			queue_free()


func _exit_state(_state: int) -> void:
	pass


func _get_default_state() -> int:
	return STATE_IDLE


# --- Damage ---

func take_damage(amount: int, knockback_direction: Vector2 = Vector2.ZERO, knockback_force: float = 0.0):
	if current_state == STATE_DYING:
		return

	health -= amount
	flash_hit()

	if knockback_force > 0:
		knockback_velocity = knockback_direction * knockback_force
		_change_state(STATE_STUNNED)


# --- Visual feedback ---

func flash_hit():
	sprite.modulate = Color(10, 10, 10)
	await get_tree().create_timer(0.05).timeout
	if is_instance_valid(self):
		sprite.modulate = Color(1, 1, 1)


func spawn_death_particles():
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 12
	particles.lifetime = 0.3
	particles.direction = Vector2.ZERO
	particles.spread = 180
	particles.initial_velocity_min = 100
	particles.initial_velocity_max = 200
	particles.gravity = Vector2.ZERO
	particles.color = sprite.modulate
	particles.global_position = global_position
	get_tree().current_scene.add_child(particles)
	await get_tree().create_timer(0.5).timeout
	particles.queue_free()
