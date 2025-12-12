extends Area2D
class_name AbilityShrine

signal unlocked(bit)

@export var ability_bit := 1
@export var message := ""

@onready var label: Label = $Popup
@onready var glow: Node2D = $Glow
@onready var particles: GPUParticles2D = $Burst

var activated := false

func _ready() -> void:
    label.visible = false

func _on_body_entered(body: Node) -> void:
    if activated:
        return
    if body is Player:
        activated = true
        body.grant_ability(ability_bit)
        emit_signal("unlocked", ability_bit)
        particles.emitting = true
        label.text = message
        label.visible = true
        glow.scale = Vector2.ONE * 1.5
        var tw := create_tween()
        tw.tween_property(glow, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        await get_tree().create_timer(1.5).timeout
        label.visible = false
