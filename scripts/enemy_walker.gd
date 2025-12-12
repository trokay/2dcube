extends CharacterBody2D
class_name EnemyWalker

signal defeated

const SPEED := 80.0
const GRAVITY := 1200.0
const FLASH_TIME := 0.12

@export var patrol_range := 120.0
@export var hp := 2

@onready var start_x := global_position.x
@onready var flash_tween := create_tween()
@onready var sprite := $Visual

var direction := -1

func _physics_process(delta: float) -> void:
    velocity.x = direction * SPEED
    velocity.y += GRAVITY * delta
    move_and_slide()

    # Turn when reaching patrol limit or edge
    if abs(global_position.x - start_x) > patrol_range or not is_on_floor():
        direction *= -1
        sprite.scale.x = direction

func take_hit(from_dir: int) -> void:
    hp -= 1
    flash()
    if hp <= 0:
        queue_free()
        emit_signal("defeated")

func flash() -> void:
    sprite.modulate = Color(1, 1, 1)
    flash_tween.kill()
    flash_tween = create_tween()
    flash_tween.tween_property(sprite, "modulate", Color(0.7, 0.7, 0.7), FLASH_TIME)
