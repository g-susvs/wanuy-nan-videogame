extends Area2D
## Velocidad heredada de la dirección de lanzamiento.
## Se inicializa mediante init() al instanciar la escena.
var velocity: Vector2 = Vector2.ZERO
## Gravedad propia de la piedra (independiente del jugador)
@export var stone_gravity: float = 800.0


# ─── Inicialización ────────────────────────────────────────────────────────────
func init(vel: Vector2) -> void:
	velocity = vel
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_deferred("monitoring", false)
	await get_tree().process_frame
	await get_tree().process_frame
	set_deferred("monitoring", true)
	# Auto-destruir tras 6 s si no impacta nada
	await get_tree().create_timer(6.0).timeout
	if is_inside_tree():
		queue_free()
		
		
# ─── Física ────────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	# Parábola real: acumulamos gravedad en Y
	velocity.y += stone_gravity * delta
	position += velocity * delta
	# Rotar el nodo según el vector velocidad (orientación de vuelo)
	rotation = atan2(velocity.y, velocity.x)
	
	
# ─── Colisión ──────────────────────────────────────────────────────────────────
func _on_body_entered(body: Node) -> void:
	if body.has_method("recibir_danio"):
		body.recibir_danio()
	queue_free()
