extends CharacterBody2D

@export var speed: float = 120.0
@export var gravity: float = 900.0
@export var stop_distance: float = 40.0
@onready var attack_area = $AttackArea
@onready var attack_cooldown = $AttackCooldown

var can_attack := true
var player_in_attack_range := false


var player = null

func _physics_process(delta: float) -> void:
	
	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if player == null or player.is_dead:
		velocity.x = 0
		move_and_slide()
		return
		
	var distance = player.global_position.x - global_position.x
		
	# Seguir solo si está lejos
	if abs(distance) > stop_distance:
		
		var direction = sign(distance)
		velocity.x = direction * speed
	else:
		velocity.x = 0
	
	move_and_slide()
	
	if player_in_attack_range:
		attack()

func attack():
	if can_attack == false:
		return
	
	can_attack = false
	
	print("ATAQUE MELEE")
	
	# Daño al jugador
	if player != null and !player.is_dead:
		player.take_damage(1)
	
	attack_cooldown.start()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body


func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player = null

func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_attack_range = true

func _on_attack_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_attack_range = false

func _on_attack_cooldown_timeout():
	can_attack = true
