extends Node

@onready var score_label = $"../CanvasLayer/ScoreLabel"
@onready var timer_label = $"../CanvasLayer/TimerLabel"
@onready var spawn_timer = $SpawnTimer
@onready var game_timer = $GameTimer

var enemy_scene = preload("res://Enemies/BaseEnemy.tscn")
var zigzag_scene = preload("res://Enemies/ZigzagEnemy.tscn")

var basic_data = preload("res://Enemies/Data/basic_virus.tres")
var zigzag_data = preload("res://Enemies/Data/zigzag_virus.tres")
var big_data = preload("res://Enemies/Data/big_virus.tres")

var score = 0
var game_duration = 90.0
var arena_size = Vector2(1920, 1080)

var base_spawn_interval = 3.0
var min_spawn_interval = 0.8
var base_enemies_per_wave = 1
var big_enemy_threshold = 30.0
var zigzag_enemy_threshold = 15.0

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.player_died.connect(_on_player_died)
	update_score_label()

func start_game():
	game_timer.wait_time = game_duration
	game_timer.one_shot = true
	game_timer.start()
	spawn_timer.wait_time = base_spawn_interval
	spawn_timer.start()

func _process(delta):
	var time_left = game_timer.time_left
	timer_label.text = "Time: " + str(int(time_left))

	var elapsed = game_duration - time_left
	var progress = elapsed / game_duration
	spawn_timer.wait_time = lerp(base_spawn_interval, min_spawn_interval, progress)

func _on_spawn_timer_timeout():
	var elapsed = game_duration - game_timer.time_left
	var progress = elapsed / game_duration
	var count = base_enemies_per_wave + int(progress * 3)

	for i in count:
		spawn_enemy(elapsed)

func spawn_enemy(elapsed: float):
	var enemy
	var roll = randf()
	
	if elapsed > big_enemy_threshold and roll > 0.6:
		enemy = enemy_scene.instantiate()
		enemy.enemy_data = big_data
	elif elapsed > zigzag_enemy_threshold and roll > 0.35 and roll <= 0.6:
		enemy = zigzag_scene.instantiate()
		enemy.enemy_data = zigzag_data
	else:
		enemy = enemy_scene.instantiate()
		enemy.enemy_data = basic_data
	enemy.global_position = get_spawn_position()
	enemy.health = enemy.enemy_data.max_health
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
	score += points
	update_score_label()

func update_score_label():
	score_label.text = "Score: " + str(score)

func _on_game_timer_timeout():
	spawn_timer.stop()
	timer_label.text = "0"
	score_label.text = "Final Score: " + str(score) + "\nPress R to restart"
	set_process(false)
	get_tree().paused = true

func _input(event):
	if event.is_action_pressed("restart") and game_timer.is_stopped():
		get_tree().paused = false
		get_tree().reload_current_scene()

func _on_player_died():
	spawn_timer.stop()
	game_timer.stop()
	timer_label.text = "GAME OVER"
	score_label.text = "Final Score: " + str(score) + "\nPress R to restart"
	set_process(false)
	get_tree().paused = true
