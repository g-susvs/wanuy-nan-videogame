extends Area2D

@export var speed: float = 400.0
@export var launch_gravity: float = 600.0
var direction: float = 1.0
var velocity: Vector2 = Vector2.ZERO

func init(dir: float, angle_offset: float = -50.0) -> void:
	direction = dir
	var angle = deg_to_rad(angle_offset)
	velocity.x = speed * cos(angle) * direction
	velocity.y = speed * sin(angle)

func _ready() -> void:
	set_deferred("monitoring", false)
	await get_tree().process_frame
	await get_tree().process_frame
	set_deferred("monitoring", true)
	await get_tree().create_timer(4.8).timeout
	if is_inside_tree():
		queue_free()

func _process(delta: float) -> void:
	velocity.y += launch_gravity * delta
	position += velocity * delta
	if direction > 0:
		rotation = atan2(velocity.y, velocity.x)
	else:
		rotation = atan2(velocity.y, velocity.x) + deg_to_rad(180)

func _on_body_entered(body: Node) -> void:
	if body.has_method("recibir_danio"):
		body.recibir_danio()
	queue_free()
