extends Node

@onready var score_label = $"../CanvasLayer/ScoreLabel"
@onready var timer_label = $"../CanvasLayer/TimerLabel"
@onready var spawn_timer = $SpawnTimer
@onready var game_timer = $GameTimer

var enemy_scene = preload("res://Enemies/BaseEnemy.tscn")
var score = 0
var game_duration = 90.0
var arena_size = Vector2(1920, 1080)

var base_spawn_interval = 3.0
var min_spawn_interval = 0.8
var base_enemies_per_wave = 1
var big_enemy_threshold = 30.0

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
	var enemy = enemy_scene.instantiate()
	enemy.global_position = get_spawn_position()
	
	enemy.enemy_data = EnemyData.new()
	
	if elapsed > big_enemy_threshold and randf() > 0.6:
		enemy.enemy_data.move_speed = 70
		enemy.enemy_data.max_health = 100
		enemy.enemy_data.contact_damage = 30
		enemy.scale = Vector2(1.5, 1.5)
	else:
		enemy.enemy_data.move_speed = 150.0
		enemy.enemy_data.max_health = 30
		enemy.enemy_data.contact_damage = 10
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

func _on_enemy_died():
	score += 1
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
