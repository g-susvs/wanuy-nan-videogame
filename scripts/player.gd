extends CharacterBody2D

@export var speed: float = 220.0
@export var jump_force: float = -420.0
@export var gravity: float = 900.0
@export var max_lives: int = 5

var lives: int
var is_dead: bool = false
var esta_atacando: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	lives = max_lives
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movimiento horizontal (bloqueado durante ataque)
	if not esta_atacando:
		var direction := Input.get_axis("ui_left", "ui_right")
		velocity.x = direction * speed

		# Voltear sprite
		if direction > 0:
			sprite.flip_h = false
		elif direction < 0:
			sprite.flip_h = true

		# Salto
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_force

		# Ataques
		if Input.is_action_just_pressed("ui_focus_next"):  # Tab = spear
			esta_atacando = true
			velocity.x = 0
			sprite.play("spear")
		elif Input.is_action_just_pressed("ui_select"):  # Enter = ataque
			esta_atacando = true
			velocity.x = 0
			sprite.play("ataque")

		_actualizar_animacion(direction)

	move_and_slide()

func _actualizar_animacion(direction: float) -> void:
	if esta_atacando:
		return
	if not is_on_floor():
		sprite.play("salto")
	elif direction != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	var anim := sprite.animation
	if anim == "spear" or anim == "ataque":
		esta_atacando = false
	elif anim == "death":
		is_dead = true
		var game_over = get_tree().root.get_node_or_null("Main/GameOverScreen")
		if game_over:
			game_over.show_game_over()
		
func recibir_danio() -> void:
	if is_dead:
		return
	lives -= 1
	if lives <= 0:
		is_dead = true
		sprite.play("death")
	else:
		esta_atacando = true
		sprite.play("death")
