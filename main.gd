extends Node

@onready var start_screen = $StartScreen
@onready var hud = $CanvasLayer
@onready var wave_spawner = $WaveSpawner

var game_started = false
var game_over = false

func _ready():
	hud.visible = false
	start_screen.visible = true
	wave_spawner.set_process(false)

func _input(event):
	if event.is_action_pressed("ui_accept") and not game_started:
		game_started = true
		start_screen.visible = false
		hud.visible = true
		wave_spawner.set_process(true)
		wave_spawner.start_game()
		var player = get_tree().get_first_node_in_group("player")
		player.can_act = true
