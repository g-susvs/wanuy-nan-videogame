
# ranged-enemy.gd — Enemigo a distancia
# Extiende la clase base Enemy para agregar comportamiento de patrulla y disparo.
extends "res://scripts/enemy/enemy.gd"

@export var projectile_scene: PackedScene
@export var patrol_left: float = 0.0
@export var patrol_right: float = 200.0

var is_waiting: bool = false
var direction: float = 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_left: RayCast2D = $RayCastLeft
@onready var ray_right: RayCast2D = $RayCastRight
@onready var shoot_timer: Timer = $Timer

func _ready() -> void:
	super._ready()
	shoot_timer.wait_time = 2.0
	shoot_timer.one_shot = false
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)

	if _player_in_range():
		velocity.x = 0
		sprite.flip_h = (player.global_position.x < global_position.x)
		_set_animation("attack")
	elif not is_waiting:
		_patrol()
	else:
		velocity.x = 0
		_set_animation("idle")

	move_and_slide()

func _patrol() -> void:
	if direction > 0 and (ray_right.is_colliding() or global_position.x >= patrol_right):
		direction = -1.0
		_wait_then_continue()
		return
	elif direction < 0 and (ray_left.is_colliding() or global_position.x <= patrol_left):
		direction = 1.0
		_wait_then_continue()
		return

	velocity.x = speed * direction
	sprite.flip_h = direction < 0
	_set_animation("run")

func _wait_then_continue() -> void:
	is_waiting = true
	await get_tree().create_timer(2.0).timeout
	is_waiting = false

var is_shooting: bool = false

func _on_shoot_timer_timeout() -> void:
	if _player_in_range() and projectile_scene != null and not is_shooting:
		_shoot()

func _shoot() -> void:
	is_shooting = true
	var angles = [-35, -40, -45, -50]
	for angle_offset in angles:
		if not is_inside_tree() or is_dead:
			break
		var proj = projectile_scene.instantiate()
		get_tree().root.add_child(proj)
		proj.global_position = global_position + Vector2(0, -20)
		var dir = sign(player.global_position.x - global_position.x)
		proj.init(dir, angle_offset)
		await get_tree().create_timer(0.4).timeout
	await get_tree().create_timer(1.0).timeout
	is_shooting = false
		


func _set_animation(anim: String) -> void:
	sprite.play(anim)
	match anim:
		"run":
			sprite.offset = Vector2(0, 0)
			sprite.scale = Vector2(0.216, 0.197)
		"idle":
			sprite.offset = Vector2(0, 0)
			sprite.scale = Vector2(0.230, 0.210)
		"attack":
			sprite.offset = Vector2(0, -6)
			sprite.scale = Vector2(0.320, 0.330)
		"death":
			sprite.offset = Vector2(0, 0)
			# Frames de 235 px de alto: con 0.33 el cuerpo queda
			# apoyado sobre el piso (base de la caja de colisión)
			sprite.scale = Vector2(0.33, 0.33)


# ─── Muerte ────────────────────────────────────────────────────────────────────
## Reemplaza el _on_death() de la clase base (que hacía queue_free directo):
## congela al enemigo, reproduce la animación y recién entonces lo libera.
func _on_death() -> void:
	set_physics_process(false)
	shoot_timer.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	_set_animation("death")
	sprite.animation_finished.connect(_on_death_animation_finished)


func _on_death_animation_finished() -> void:
	queue_free()
