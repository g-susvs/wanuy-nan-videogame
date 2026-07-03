# melee_enemy.gd — Enemigo cuerpo a cuerpo
# Extiende la clase base Enemy para agregar comportamiento de persecución y ataque melee.
extends "res://scripts/enemy/enemy.gd"

@export var stop_distance: float = 50.0
## Alcance del rayo de piso hacia el frente (desde el centro del colisionador).
@export var raycast_distance: float = 32.0

## El colisionador está desplazado en X respecto al origen del nodo.
const BODY_CENTER_X: float = -12.0

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
	_aim_floor_ray(patrol_direction)

## Coloca el rayo de piso al frente según la dirección (recto hacia abajo).
func _aim_floor_ray(dir: float) -> void:
	floor_raycast.position.x = BODY_CENTER_X + dir * raycast_distance

## ¿Hay piso justo delante en la dirección dada? Actualiza el rayo en el acto.
func _floor_ahead(dir: float) -> bool:
	_aim_floor_ray(dir)
	floor_raycast.force_raycast_update()
	return floor_raycast.is_colliding()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_behavior()
	move_and_slide()

func handle_behavior() -> void:
	# Persigue sólo si el jugador está vivo y a rango; si no, patrulla.
	# (La base asigna 'player' al aparecer, por eso gateamos por distancia.)
	if player != null and not player.is_dead and _player_in_range():
		handle_chase()
	else:
		handle_patrol()

func handle_patrol() -> void:
	# Girar en el borde ANTES de moverse (no pisar el vacío este frame)
	if is_on_floor() and not _floor_ahead(patrol_direction):
		change_direction()
	velocity.x = patrol_direction * speed
	update_sprite_direction(animated_sprite, patrol_direction)
	if animated_sprite.animation != "step1":
		animated_sprite.play("step1")

func handle_chase() -> void:
	var distance: float = player.global_position.x - global_position.x

	# Cerca: atacar
	if abs(distance) <= stop_distance:
		velocity.x = 0
		if player_in_attack_range:
			attack()
		elif animated_sprite.animation != "stand":
			animated_sprite.play("stand")
		return

	# Perseguir en la dirección del jugador
	var dir: float = -1.0 if distance < 0.0 else 1.0
	patrol_direction = dir
	# Si hay un abismo delante, no perseguir al vacío: detenerse en el borde
	if is_on_floor() and not _floor_ahead(dir):
		velocity.x = 0
		if animated_sprite.animation != "stand":
			animated_sprite.play("stand")
	else:
		velocity.x = dir * speed
		update_sprite_direction(animated_sprite, dir)
		if animated_sprite.animation != "step1":
			animated_sprite.play("step1")

func change_direction() -> void:
	patrol_direction *= -1
	_aim_floor_ray(patrol_direction)

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

func _on_death() -> void:
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	animated_sprite.play("death")
	animated_sprite.animation_finished.connect(_on_death_animation_finished)

func _on_death_animation_finished() -> void:
	queue_free()

func _on_patrol_timer_timeout() -> void:
	change_direction()
