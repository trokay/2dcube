extends Area2D
class_name Projectile

const SPEED := 260.0
const LIFETIME := 4.0

var direction := Vector2.RIGHT

func _ready() -> void:
    $LifeTimer.start(LIFETIME)

func _physics_process(delta: float) -> void:
    global_position += direction.normalized() * SPEED * delta

func _on_body_entered(body: Node) -> void:
    if body.has_method("take_damage"):
        body.take_damage(1)
    queue_free()

func _on_LifeTimer_timeout() -> void:
    queue_free()
