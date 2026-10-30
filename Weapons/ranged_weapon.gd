extends BaseWeapon

const PROJECTILE_SCENE = preload("res://Weapons/Projectile.tscn")

# --- Projectile data per combo hit (set in the Inspector) ---
@export var speed_chain: Array[int] = []
@export var scale_chain: Array[Vector2] = []


# --- Hook override ---

func _on_hit_started(_index: int) -> void:
	spawn_projectile()


func spawn_projectile():
	var bolt = PROJECTILE_SCENE.instantiate()
	bolt.global_position = global_position
	bolt.rotation = get_parent().global_rotation
	bolt.damage = damage_chain[combo_index]
	bolt.speed = speed_chain[combo_index]
	bolt.knockback_force = knockback_chain[combo_index]
	bolt.scale = scale_chain[combo_index]
	get_tree().current_scene.add_child(bolt)
