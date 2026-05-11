extends CharacterBody2D

@export var speed: float = 60.0
@export var gravity: float = 900.0
@export var detection_range: float = 300.0
@export var projectile_scene: PackedScene
@export var patrol_left: float = 0.0
@export var patrol_right: float = 200.0

var direction: float = 1.0
var is_waiting: bool = false
var player: CharacterBody2D = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_left: RayCast2D = $RayCastLeft
@onready var ray_right: RayCast2D = $RayCastRight
@onready var shoot_timer: Timer = $Timer

func _ready() -> void:
	shoot_timer.wait_time = 2.0
	shoot_timer.one_shot = false
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if _player_in_range():
		velocity.x = 0
		sprite.flip_h = (player.global_position.x < global_position.x)
		sprite.play("attack")
	elif not is_waiting:
		_patrol()
	else:
		velocity.x = 0
		sprite.play("idle")

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
	sprite.play("run")

func _wait_then_continue() -> void:
	is_waiting = true
	await get_tree().create_timer(2.0).timeout
	is_waiting = false

func _player_in_range() -> bool:
	if player == null:
		return false
	return global_position.distance_to(player.global_position) < detection_range

func _on_shoot_timer_timeout() -> void:
	if _player_in_range() and projectile_scene != null:
		_shoot()

func _shoot() -> void:
	var proj = projectile_scene.instantiate()
	get_tree().root.add_child(proj)
	proj.global_position = global_position + Vector2(0, -20)
	var dir = sign(player.global_position.x - global_position.x)
	proj.init(dir)
