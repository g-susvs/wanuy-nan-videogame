@tool
extends CanvasLayer

@onready var hearts_container: HBoxContainer = $PanelContainer/HeartsContainer
@onready var coca_panel: PanelContainer = $CocaPanel
@onready var coca_time_label: Label = $CocaPanel/CocaContainer/CocaTimeLabel

const HEART_FULL  = preload("res://assets/ui/hearth.png")
const HEART_EMPTY = preload("res://assets/ui/empty-hearth.png")
const HEART_SIZE  = Vector2(44, 44)

# Solo visible en el editor: cuántos corazones mostrar de preview
@export var preview_lives: int = 5 :
	set(value):
		preview_lives = value
		if Engine.is_editor_hint() and hearts_container:
			_crear_contenedor_corazones(preview_lives)
			_dibujar_corazones(preview_lives, preview_lives)

var max_lives: int = 5
var player: Node = null

func _ready() -> void:
	# En el editor: mostrar preview con los valores configurados
	if Engine.is_editor_hint():
		_crear_contenedor_corazones(preview_lives)
		_dibujar_corazones(preview_lives, preview_lives)
		return

	# En el juego: conectar al jugador real
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		max_lives = player.max_lives
		_crear_contenedor_corazones(max_lives)
		_dibujar_corazones(player.lives, max_lives)
		player.vida_cambiada.connect(_on_vida_cambiada)

# ─── Contador del power-up hoja de coca ────────────────────────────────────────

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# Leer el tiempo restante directamente del jugador
	var tiempo: float = player.coca_time_left if is_instance_valid(player) else 0.0
	if tiempo > 0.0:
		coca_panel.visible = true
		# Segundos a dos dígitos, redondeando hacia arriba: 10s → 09s → … → 01s
		coca_time_label.text = "%02ds" % ceili(tiempo)
	elif coca_panel.visible:
		coca_panel.visible = false

func _dibujar_corazones(vidas_actuales: int, total: int) -> void:
	for i in range(hearts_container.get_child_count()):
		var heart = hearts_container.get_child(i)
		heart.texture = HEART_FULL if i < vidas_actuales else HEART_EMPTY

func _crear_contenedor_corazones(total: int) -> void:
	# Limpiar los existentes antes de recrear
	for child in hearts_container.get_children():
		child.queue_free()
	for i in range(total):
		var heart = TextureRect.new()
		heart.texture = HEART_FULL
		heart.custom_minimum_size = HEART_SIZE
		heart.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		heart.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hearts_container.add_child(heart)

func _on_vida_cambiada(vidas: int) -> void:
	_dibujar_corazones(vidas, max_lives)
