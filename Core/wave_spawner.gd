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
var remaining_count : int = 0
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
	
	spawn_enemy(entry)
	
	if spawn_queue.is_empty():
		spawn_timer.stop()
		state = State.CLEARING
	


func spawn_enemy(entry: SpawnEntry):
	
	var enemy = entry.enemy_scene.instantiate()
	enemy.enemy_data = entry.enemy_data
	
	enemy.global_position = get_spawn_position()
	enemy.died.connect(_on_enemy_died)
	get_tree().current_scene.add_child(enemy)

func get_spawn_position() -> Vector2:
	var side = randi() % 4
	match side:
		0: return Vector2(randf_range(0, arena_size.x), -50)
		1: return Vector2(randf_range(0, arena_size.x), arena_size.y + 50)
		2: return Vector2(-50, randf_range(0, arena_size.y))
		3: return Vector2(arena_size.x + 50, randf_range(0, arena_size.y))
	return Vector2.ZERO

func _on_enemy_died(points: int):
	remaining_count -= 1
	print("died, remaining: ", remaining_count)
	score += points
	update_score_label()
	
	if remaining_count == 0:
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
	remaining_count = spawn_queue.size()
	
	spawn_timer.wait_time = waves[wave_index].time_gap
	spawn_timer.start()
	
	timer_label.text = "Wave %d / %d" % [wave_index + 1, waves.size()]
	state = State.SPAWNING
