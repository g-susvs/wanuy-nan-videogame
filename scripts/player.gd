extends CharacterBody2D

# ─── Exportables ───────────────────────────────────────────────────────────────
@export var speed: float = 220.0
@export var jump_force: float = -420.0
@export var gravity: float = 900.0
@export var max_lives: int = 5

## Arrastra aquí la escena res://scenes/player/piedra.tscn desde el Inspector
@export var piedra_scene: PackedScene
## Velocidad de lanzamiento de la piedra (px/s)
@export var stone_speed: float = 550.0
## Gravedad simulada de la piedra para la trayectoria
@export var stone_gravity: float = 800.0

## ─── Power-up hoja de coca ───
## Duración del potenciador en segundos
@export var coca_duration: float = 10.0
## Cantidad de piedras del disparo múltiple
@export var multi_shot_count: int = 4
## Apertura total del abanico en grados
@export var multi_shot_spread_deg: float = 24.0

@onready var attack_area = CollisionShape2D

# ─── Estado ────────────────────────────────────────────────────────────────────
var lives: int
var is_dead: bool = false
var esta_atacando: bool = false
var is_invincible: bool = false
var is_aiming: bool = false        # true mientras se mantiene clic izquierdo
var coca_time_left: float = 0.0    # > 0 → disparo múltiple activo

# Señal que emite el nuevo valor de vidas cada vez que cambia
signal vida_cambiada(vidas_actuales: int)

# ─── Nodos ─────────────────────────────────────────────────────────────────────
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker: Marker2D = $Marker2D

var trajectory_line: Line2D   # creado en código para no tocar la escena

# ─── Inicialización ────────────────────────────────────────────────────────────

func _ready() -> void:
	lives = max_lives
	sprite.play("idle")
	_setup_trajectory()

func _setup_trajectory() -> void:
	trajectory_line = Line2D.new()
	# top_level = true → las posiciones son globales aunque sea hijo del jugador
	trajectory_line.top_level = true
	trajectory_line.width = 4.0

	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.97, 1.0, 0.97, 0.9))
	gradient.set_color(1, Color(0.5, 0, 0, 0))
	trajectory_line.gradient = gradient

	# Curva de ancho: grueso en el origen, fino al final
	var w_curve := Curve.new()
	w_curve.add_point(Vector2(0.0, 1.0))
	w_curve.add_point(Vector2(1.0, 0.1))
	trajectory_line.width_curve = w_curve

	trajectory_line.visible = false
	add_child(trajectory_line)

# ─── Proceso físico ────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Countdown del power-up de la hoja de coca
	if coca_time_left > 0.0:
		coca_time_left -= delta
		if coca_time_left <= 0.0:
			sprite.modulate = Color.WHITE  # fin del potenciador

	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_aiming:
		# El jugador queda quieto mientras apunta con la honda
		velocity.x = 0
		# Voltear sprite hacia la posición del cursor
		var mouse_pos := get_global_mouse_position()
		sprite.flip_h = mouse_pos.x < global_position.x

	elif not esta_atacando:
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

# ─── Proceso visual (trayectoria) ──────────────────────────────────────────────

func _process(_delta: float) -> void:
	if is_aiming and not is_dead:
		_update_trajectory()

# ─── Entrada del mouse ─────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if is_dead:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Iniciar apuntado solo si no hay otro ataque en curso
			if not esta_atacando and not is_aiming and not is_invincible:
				is_aiming = true
				sprite.play("honda")
		else:
			# Soltar clic → animación de lanzamiento + disparo
			if is_aiming:
				is_aiming = false
				trajectory_line.visible = false
				esta_atacando = true
				sprite.play("soltar")
				_disparar_honda()

# ─── Punto de origen de la piedra ─────────────────────────────────────────────

## Devuelve la posición global desde donde sale la piedra.
## Respeta el flip horizontal del sprite: si el personaje mira a la izquierda,
## el offset X del Marker2D se espeja automáticamente.
## Ajusta la posición del Marker2D en el editor para alinearla con la mano.
func _get_spawn_point() -> Vector2:
	var offset := marker.position
	if sprite.flip_h:
		offset.x = -offset.x
	return global_position + offset

# ─── Trayectoria parabólica ────────────────────────────────────────────────────

func _update_trajectory() -> void:
	trajectory_line.visible = true
	trajectory_line.clear_points()

	var start := _get_spawn_point()
	var mouse_pos := get_global_mouse_position()
	var dir := (mouse_pos - start).normalized()
	var vel := dir * stone_speed

	# Simular 40 pasos de 0.05 s = 2 segundos de vuelo
	var step_time := 0.05
	var steps := 40

	for i in range(steps):
		var t := i * step_time
		var px := start.x + vel.x * t
		var py := start.y + vel.y * t + 0.5 * stone_gravity * t * t
		trajectory_line.add_point(Vector2(px, py))

# ─── Disparo ───────────────────────────────────────────────────────────────────

func _disparar_honda() -> void:
	if piedra_scene == null:
		push_warning("⚠️  Asigna 'Piedra Scene' en el Inspector del nodo Player (res://scenes/player/piedra.tscn).")
		_reanudar_animacion()
		return

	var mouse_pos := get_global_mouse_position()
	var start := _get_spawn_point()
	var dir := (mouse_pos - start).normalized()

	if coca_time_left > 0.0 and multi_shot_count > 1:
		# Disparo múltiple: abanico angular centrado en la dirección de apuntado.
		# Cada piedra sigue su propia parábola (la gravedad la aplica piedra.gd).
		var spread := deg_to_rad(multi_shot_spread_deg)
		for i in range(multi_shot_count):
			var t := float(i) / (multi_shot_count - 1)  # 0..1
			var angle := -spread / 2.0 + spread * t
			_lanzar_piedra(start, dir.rotated(angle))
	else:
		_lanzar_piedra(start, dir)
	# La animación "soltar" ya está corriendo; _reanudar_animacion()
	# se llamará cuando animation_finished la detecte.

func _lanzar_piedra(start: Vector2, dir: Vector2) -> void:
	var piedra = piedra_scene.instantiate()
	# Añadir como hijo del padre del jugador para que no se mueva con él
	get_parent().add_child(piedra)
	piedra.global_position = start
	piedra.init(dir * stone_speed)

func _reanudar_animacion() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	_actualizar_animacion(direction)

# ─── Ataque cuerpo a cuerpo ────────────────────────────────────────────────────

func golpear_enemigos() -> void:
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("recibir_danio"):
			body.recibir_danio(1)

# ─── Animación ─────────────────────────────────────────────────────────────────

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
	if anim == "spear" or anim == "ataque" or anim == "hurt" or anim == "soltar":
		esta_atacando = false
	elif anim == "death":
		is_dead = true
		var game_over = get_tree().root.get_node_or_null("Main/GameOverScreen")
		if game_over:
			game_over.show_game_over()

# ─── Power-up hoja de coca ─────────────────────────────────────────────────────

## Activa (o renueva) el disparo múltiple durante coca_duration segundos.
## Lo llama coca_leaf.gd al ser recolectada.
func recolectar_coca() -> void:
	coca_time_left = coca_duration
	# Tinte dorado mientras dura el potenciador
	sprite.modulate = Color(1.3, 1.1, 0.6)

# ─── Daño y vida ───────────────────────────────────────────────────────────────

func recibir_danio() -> void:
	if is_dead or is_invincible:
		return
	lives -= 1
	vida_cambiada.emit(lives)
	if lives <= 0:
		is_dead = true
		sprite.play("death")
	else:
		_parpadear()

func _parpadear() -> void:
	is_invincible = true
	var tween := create_tween()
	# Parpadea 4 veces: alterna opacidad entre 0.15 y 1
	for i in range(4):
		tween.tween_property(sprite, "modulate:a", 0.15, 0.08)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.08)
	# Al terminar, quita la invencibilidad
	tween.tween_callback(func(): is_invincible = false)
