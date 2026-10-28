extends Node

@onready var score_label = $"../CanvasLayer/ScoreLabel"
@onready var timer_label = $"../CanvasLayer/TimerLabel"
@onready var spawn_timer = $SpawnTimer
@onready var intermission_timer = $IntermissionTimer

var score = 0
var arena_size = Vector2(1920, 1080)


@export var waves : Array[WaveData] = []
var wave_index : int = 0
enum State { IDLE, SPAWNING, CLEARING, INTERMISSION }
var state : State = State.IDLE
var alive_count : int = 0
var spawn_queue : Array[SpawnEntry] = []


func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.player_died.connect(_on_player_died)
	update_score_label()

func start_game():
	start_wave()
	


func _on_spawn_timer_timeout():
	var entry = spawn_queue.pop_front()
	
	spawn_enemy(entry, get_spawn_position())
	
	if spawn_queue.is_empty():
		spawn_timer.stop()
		state = State.CLEARING
	


func spawn_enemy(entry: SpawnEntry, pos: Vector2, copy: bool = false):
	
	var enemy = entry.enemy_scene.instantiate()
	enemy.enemy_data = entry.enemy_data
	enemy.is_copy = copy
	enemy.global_position = pos

	alive_count += 1
	enemy.died.connect(_on_enemy_died)
	enemy.copy_requested.connect(_on_copy_requested.bind(entry))

	get_tree().current_scene.add_child(enemy)

func _on_copy_requested(pos: Vector2, entry: SpawnEntry):
	spawn_enemy(entry, pos, true)

func get_spawn_position() -> Vector2:
	var side = randi() % 4
	match side:
		0: return Vector2(randf_range(0, arena_size.x), -50)
		1: return Vector2(randf_range(0, arena_size.x), arena_size.y + 50)
		2: return Vector2(-50, randf_range(0, arena_size.y))
		3: return Vector2(arena_size.x + 50, randf_range(0, arena_size.y))
	return Vector2.ZERO

func _on_enemy_died(points: int):
	alive_count -= 1
	print(alive_count)
	score += points
	update_score_label()
	_check_wave_cleared()
	

func _check_wave_cleared():
	if state == State.CLEARING and alive_count == 0:
		state = State.INTERMISSION
		intermission_timer.start()

func update_score_label():
	score_label.text = "Score: " + str(score)

func _on_intermission_timer_timeout():
	print("intermission over, index: ", wave_index)
	wave_index += 1
	if wave_index < waves.size():
		start_wave()
	else:
		_on_victory()
	

func _on_victory():
	spawn_timer.stop()
	intermission_timer.stop()
	state = State.IDLE
	timer_label.text = "YOU WIN"
	score_label.text = "Final Score: " + str(score) + "\nPress R to restart"
	get_tree().paused = true

func _input(event):
	if event.is_action_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()
	
	#debug
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		var enemies = get_tree().get_nodes_in_group("enemy")
		if not enemies.is_empty():
			var e = enemies.pick_random()
			e.request_copy(e.global_position + Vector2(60, 0))

func _on_player_died():
	spawn_timer.stop()
	intermission_timer.stop()
	timer_label.text = "GAME OVER"
	score_label.text = "Final Score: " + str(score) + "\nPress R to restart"
	get_tree().paused = true


#state machine
func start_wave():
	var current_wave = waves[wave_index]
	spawn_queue.clear()
	
	for entry in current_wave.spawn_entries:
		for i in entry.count:
			spawn_queue.append(entry)
	
	spawn_queue.shuffle()
	
	spawn_timer.wait_time = waves[wave_index].time_gap
	spawn_timer.start()
	
	timer_label.text = "Wave %d / %d" % [wave_index + 1, waves.size()]
	state = State.SPAWNING
