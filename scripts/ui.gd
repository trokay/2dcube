extends Control
class_name GameUI

@onready var hearts: HBoxContainer = $Hearts
@onready var ability_label: Label = $AbilityLabel

var max_hp := 5

func set_max_hp(value: int) -> void:
    max_hp = value
    redraw_hp(value)

func redraw_hp(current_hp: int) -> void:
    for child in hearts.get_children():
        child.queue_free()
    for i in range(max_hp):
        var poly := Polygon2D.new()
        var size := 10
        poly.polygon = [Vector2(0, -size/2), Vector2(size/2, 0), Vector2(0, size/2), Vector2(-size/2, 0)]
        poly.color = Color(1, 1, 1, 1 if i < current_hp else 0.3)
        hearts.add_child(poly)

func show_ability(text: String) -> void:
    ability_label.text = text
    ability_label.modulate.a = 1
    var tw := create_tween()
    tw.tween_property(ability_label, "modulate:a", 0.0, 1.2).set_delay(1)
