extends CharacterBody2D

@export var speed: float = 220.0
@export var jump_force: float = -420.0
@export var gravity: float = 900.0
@export var max_lives: int = 5

var lives: int
var is_dead: bool = false

func _ready() -> void:
	lives = max_lives

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Movimiento horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
	
	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force
	
	move_and_slide()

func take_damage(amount):
	if is_dead:
		return
		
	lives -= amount
	print("VIDAS: ", lives)
	if lives <= 0:
		die()
		
func die():
	is_dead = true
