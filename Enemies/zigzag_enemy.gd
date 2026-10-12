class_name ZigzagEnemy
extends BaseEnemy
## Fast flanker: closes in on the player while weaving side to side.
## Only overrides how it picks a direction; health, knockback, and death come from BaseEnemy.
 
@export var zigzag_frequency: float = 2.0   # how fast it weaves (higher = tighter zigzag)
@export var zigzag_amplitude: float = 2.5   # how hard it swings sideways (0 = straight line)
@export var straighten_range: float = 80.0  # stops weaving this close, so it lunges instead of orbiting
 
# Random starting phase so enemies from the same wave don't weave in sync
var _phase: float = randf() * TAU
 
var phase_offset : float = 0.0

func _ready():
	super._ready()
	phase_offset = randf_range(0.0, TAU) 


func _get_chase_direction(delta: float) -> Vector2:
	var to_player := super(delta)
	if to_player == Vector2.ZERO:
		return Vector2.ZERO
 
	_phase += delta * zigzag_frequency
 
	var amplitude := zigzag_amplitude
	if global_position.distance_to(_player.global_position) < straighten_range:
		amplitude = 0.0
 
	var sideways := to_player.orthogonal()
	return (to_player + sideways * sin(_phase) * amplitude)
