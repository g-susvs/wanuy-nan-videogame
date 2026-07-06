extends RigidBody2D
## Piedra lanzada por el jugador.
## El vuelo, rebote y rodado los maneja el motor de física
## (RigidBody2D + PhysicsMaterial); aquí solo va el daño y el despawn.

## Segundos que sigue rodando tras el primer impacto contra una superficie
@export var roll_lifetime: float = 1.2
## Vida máxima total si no impacta nada
@export var max_lifetime: float = 6.0

var _despawn_started: bool = false


# ─── Inicialización ────────────────────────────────────────────────────────────
func init(vel: Vector2) -> void:
	linear_velocity = vel


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Auto-destruir tras max_lifetime si no impacta nada
	await get_tree().create_timer(max_lifetime).timeout
	if is_inside_tree():
		queue_free()


# ─── Colisión ──────────────────────────────────────────────────────────────────
func _on_body_entered(body: Node) -> void:
	if _despawn_started:
		# Ya impactó antes: la piedra es inofensiva, los rebotes no dañan
		return
	if body.has_method("recibir_danio"):
		# Enemigo: aplicar daño y desaparecer al instante
		body.recibir_danio()
		queue_free()
	else:
		# Superficie. Pero si en este mismo paso de física también está
		# tocando a un enemigo (impacto rasante a la altura de los pies),
		# ese contacto cuenta como impacto directo: dañar en vez de rebotar.
		for other in get_colliding_bodies():
			if other.has_method("recibir_danio"):
				other.recibir_danio()
				queue_free()
				return
		# Solo suelo/pared: el motor ya la hace rebotar y rodar;
		# desde aquí deja de hacer daño y está por desaparecer.
		_iniciar_despawn()


# ─── Despawn ───────────────────────────────────────────────────────────────────
## Marca la piedra como inofensiva, la hace parpadear como aviso
## y la libera tras roll_lifetime segundos.
func _iniciar_despawn() -> void:
	_despawn_started = true
	# Parpadeo: alterna la opacidad del sprite en loop hasta que se libere
	var tween := create_tween().set_loops()
	tween.tween_property($Sprite2D, "modulate:a", 0.25, 0.12)
	tween.tween_property($Sprite2D, "modulate:a", 1.0, 0.12)

	await get_tree().create_timer(roll_lifetime).timeout
	if is_inside_tree():
		queue_free()
