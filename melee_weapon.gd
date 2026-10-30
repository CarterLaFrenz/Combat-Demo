class_name MeleeWeapon
extends BaseWeapon

@onready var hitbox = $HitboxArea

# --- Hit feel (set per weapon in the Inspector) ---
@export var hitlag_duration: float = 0.05
@export var shake_strength: float = 5.0
@export var shake_duration: float = 0.1

var hit_enemies = []


func _ready():
	disable_hitbox()


# --- Hook overrides ---

func _on_hit_started(_index: int) -> void:
	hit_enemies.clear()

func _on_string_ended() -> void:
	disable_hitbox()
	hit_enemies.clear()


# --- Hitbox (toggled by animation method call tracks) ---

func enable_hitbox():
	hitbox.monitoring = true
	hitbox.monitorable = true

func disable_hitbox():
	hitbox.monitoring = false
	hitbox.monitorable = false


func _on_hitbox_area_area_entered(area):
	if area.is_in_group("enemy_hurtbox") and area not in hit_enemies:
		hit_enemies.append(area)
		var player = get_tree().get_first_node_in_group("player")
		var knockback_dir = (area.global_position - player.global_position).normalized()
		area.get_parent().take_damage(damage_chain[combo_index], knockback_dir, knockback_chain[combo_index])
		CombatEffects.hitlag(hitlag_duration)
		CombatEffects.screen_shake(shake_strength, shake_duration)
