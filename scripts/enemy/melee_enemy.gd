# melee_enemy.gd — Enemigo cuerpo a cuerpo
# Extiende la clase base Enemy para agregar comportamiento de persecución y ataque melee.
extends "res://scripts/enemy/enemy.gd"

@export var stop_distance: float = 50.0
@export var raycast_distance: float = 12.0

@onready var attack_area = $AttackArea
@onready var attack_cooldown = $AttackCooldown
@onready var patrol_timer = $PatrolTimer
@onready var floor_raycast = $FloorRayCast
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var can_attack: bool = true
var player_in_attack_range: bool = false

var esta_atacando: bool = false

func _ready() -> void:
	super._ready() 
	floor_raycast.position.x = raycast_distance

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_behavior()
	move_and_slide()

func handle_behavior() -> void:
	var should_patrol = player == null or player.is_dead
	if should_patrol:
		handle_patrol()
	else:
		handle_chase()

func handle_patrol() -> void:
	velocity.x = patrol_direction * speed
	update_sprite_direction(animated_sprite, patrol_direction)
	animated_sprite.play("step1")
	if is_on_floor():
		if velocity.x != 0 and !floor_raycast.is_colliding():
			change_direction()

func handle_chase() -> void:
	var distance = player.global_position.x - global_position.x

	# Perseguir jugador
	if abs(distance) > stop_distance:
		var dir = sign(distance)
		velocity.x = dir * speed
		update_sprite_direction(animated_sprite, dir)
		if animated_sprite.animation != "step1":
			animated_sprite.play("step1")

	# Cerca del jugador
	else:
		velocity.x = 0

		# Atacar
		if player_in_attack_range:
			attack()

		# Idle solo si NO está atacando
		elif animated_sprite.animation != "stand":
			animated_sprite.play("stand")

func change_direction() -> void:
	patrol_direction *= -1
	floor_raycast.position.x = raycast_distance * patrol_direction

func attack() -> void:
	if can_attack == false:
		return

	can_attack = false
	animated_sprite.play("attack")

	# Daño al jugador
	if player != null and !player.is_dead:
		player.recibir_danio()

	attack_cooldown.start()

func _on_detection_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player = null

func _on_attack_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_attack_range = true

func _on_attack_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_attack_range = false

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func _on_patrol_timer_timeout() -> void:
	change_direction()
