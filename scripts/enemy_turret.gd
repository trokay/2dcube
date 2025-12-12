extends Node2D
class_name EnemyTurret

signal defeated

@export var fire_interval := 1.8
@export var projectile_scene: PackedScene

@onready var fire_timer: Timer = $FireTimer
@onready var muzzle: Node2D = $Muzzle
@onready var sprite: Node2D = $Visual

func _ready() -> void:
    fire_timer.wait_time = fire_interval
    fire_timer.start()

func _on_FireTimer_timeout() -> void:
    if projectile_scene == null:
        return
    var proj: Node2D = projectile_scene.instantiate()
    proj.global_position = muzzle.global_position
    proj.rotation = rotation
    proj.set("direction", Vector2.RIGHT.rotated(rotation))
    get_tree().current_scene.add_child(proj)

func take_hit(from_dir: int) -> void:
    queue_free()
    emit_signal("defeated")
