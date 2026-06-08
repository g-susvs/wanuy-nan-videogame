# enemy_spawner.gd
extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 20.0

func _ready() -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = spawn_interval
	timer.timeout.connect(_spawn_enemy)
	timer.start()

func _spawn_enemy() -> void:
	if enemy_scene == null or get_child_count() <= 1:
		return
	# toma un hijo random (saltando el timer que es el primer hijo)
	var puntos = []
	for child in get_children():
		if child is Marker2D:
			puntos.append(child)
	if puntos.is_empty():
		return
	var pos = puntos[randi() % puntos.size()].global_position
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = pos
