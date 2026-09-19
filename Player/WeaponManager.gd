extends Node

@onready var weapons = [$HeavyWeapon, $LightWeapon, $RangedWeapon]
@onready var player = get_tree().get_first_node_in_group("player")
var current_index = 0

func _ready():
	for i in weapons.size():
		weapons[i].visible = (i == current_index)
	connect_weapon(weapons[current_index])

func _input(event):
	if not player.can_act:
		return
	if weapons[current_index].is_attacking:
		return
	if event.is_action_pressed("cycle_next"):
		switch_weapon((current_index + 1) % weapons.size())
	elif event.is_action_pressed("cycle_previous"):
		switch_weapon((current_index - 1 + weapons.size()) % weapons.size())

func switch_weapon(new_index):
	disconnect_weapon(weapons[current_index])
	weapons[current_index].visible = false
	current_index = new_index
	weapons[current_index].visible = true
	connect_weapon(weapons[current_index])

func connect_weapon(weapon):
	weapon.attack_started.connect(player.on_attack_started)
	weapon.attack_finished.connect(player.on_attack_finished)

func disconnect_weapon(weapon):
	weapon.attack_started.disconnect(player.on_attack_started)
	weapon.attack_finished.disconnect(player.on_attack_finished)
