extends Area2D
## Zona mortal al fondo de los precipicios.
## Si el jugador cae, pierde una vida y reaparece en el último checkpoint
## superado (posiciones en coordenadas locales del nivel).

## Puntos de reaparición, en orden de izquierda a derecha (coords locales del nivel).
@export var checkpoints: PackedVector2Array

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	# Resta una vida (respeta invencibilidad/parpadeo del propio jugador)
	if body.has_method("recibir_danio"):
		body.recibir_danio()
	# Reaparece en el checkpoint más cercano a la izquierda de la caída
	var fall_x: float = body.global_position.x
	var target: Vector2 = checkpoints[0] if checkpoints.size() > 0 else Vector2.ZERO
	for cp in checkpoints:
		var cp_global_x: float = get_parent().to_global(cp).x
		if cp_global_x <= fall_x and cp_global_x >= get_parent().to_global(target).x:
			target = cp
	body.global_position = get_parent().to_global(target)
	if body is CharacterBody2D:
		body.velocity = Vector2.ZERO
