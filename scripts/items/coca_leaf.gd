extends Area2D
## Ítem recolectable: hoja de coca.
## El jugador lo recoge para potenciar sus habilidades.
## El sprite lo maneja un AnimatedSprite2D; aquí solo va la flotación,
## el brillo palpitante (modulate) y la recolección.

# ─── Configuración de animación ──────────────────────────────────────────────
## Velocidad del vaivén de flotación (rad/s)
@export var float_speed: float = 2.0
## Amplitud vertical de la flotación en píxeles
@export var float_amplitude: float = 4.0
## Velocidad del pulso del brillo (rad/s)
@export var glow_speed: float = 3.0

# ─── Estado interno ──────────────────────────────────────────────────────────
var _time: float = 0.0
var _base_y: float = 0.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


# ─── Inicialización ──────────────────────────────────────────────────────────
func _ready() -> void:
	_base_y = position.y
	body_entered.connect(_on_body_entered)


# ─── Animación ───────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	_time += delta
	# Flotación: se eleva y baja suavemente
	position.y = _base_y + sin(_time * float_speed) * float_amplitude
	# Brillo palpitante: el sprite "respira" entre su color normal y uno más luminoso
	var pulse: float = 0.5 + 0.5 * sin(_time * glow_speed)
	_sprite.modulate = Color(1.0, 1.0, 1.0).lerp(Color(1.4, 1.8, 1.2), pulse)


# ─── Recolección ─────────────────────────────────────────────────────────────
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("recolectar_coca"):
		body.recolectar_coca()
		queue_free()
