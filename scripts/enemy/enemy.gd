# enemy.gd — Clase base para todos los enemigos
# Hereda de CharacterBody2D y define los valores y comportamientos compartidos.
# Los scripts de enemigos específicos deben usar: extends "res://scripts/enemy/enemy.gd"
class_name Enemy
extends CharacterBody2D

# --- Parámetros base (priorizados de ranged-enemy) ---
@export var speed: float = 60.0
@export var gravity: float = 900.0
@export var detection_range: float = 300.0

# --- Estado compartido ---
var player: Node = null
var patrol_direction: float = 1.0
var is_dead: bool = false

@export var max_lives: int = 1
var lives: int

# --- Inicialización del jugador ---
func _ready() -> void:
	lives = max_lives
	_find_player()

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

# --- Gravedad compartida ---
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

# --- Detección de rango del jugador ---
func _player_in_range() -> bool:
	if player == null:
		return false
	return global_position.distance_to(player.global_position) < detection_range

# --- Dirección del sprite (flip horizontal) ---
func update_sprite_direction(sprite: AnimatedSprite2D, dir: float) -> void:
	if dir > 0:
		sprite.flip_h = false
	elif dir < 0:
		sprite.flip_h = true

func recibir_danio(_cantidad: int = 1) -> void:
	if is_dead:
		return
	lives -= 1
	if lives <= 0:
		is_dead = true
		_on_death()

func _on_death() -> void:
	queue_free()
