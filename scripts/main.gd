extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var ui_layer: CanvasLayer = $CanvasLayer
@onready var ui: GameUI = $CanvasLayer/UI
@onready var level: Node2D = $Level1
@onready var player: Player = $Level1/Player
@onready var fade_rect: ColorRect = $Fade

func _ready() -> void:
    camera.make_current()
    player.connect("took_damage", Callable(self, "_on_player_damage"))
    player.connect("died", Callable(self, "_on_player_died"))
    player.connect("ability_unlocked", Callable(self, "_on_ability_unlocked"))
    ui.set_max_hp(player.MAX_HP)
    ui.redraw_hp(player.hp)
    fade_rect.visible = true
    fade_rect.color = Color(0, 0, 0, 1)
    var tw := create_tween()
    tw.tween_property(fade_rect, "color:a", 0.0, 0.8)

func _process(delta: float) -> void:
    camera.position = player.global_position

func _on_player_damage(hp: int) -> void:
    ui.redraw_hp(hp)
    screen_shake(4, 0.1)

func _on_player_died() -> void:
    var tw := create_tween()
    fade_rect.visible = true
    tw.tween_property(fade_rect, "color:a", 1.0, 0.6)
    await tw.finished
    get_tree().reload_current_scene()

func _on_ability_unlocked(bit: int) -> void:
    match bit:
        Player.Ability.DOUBLE_JUMP:
            ui.show_ability("Double Jump Unlocked")
        Player.Ability.DASH:
            ui.show_ability("Dash Unlocked")
        Player.Ability.WALL:
            ui.show_ability("Wall Jump Unlocked")
    screen_shake(6, 0.2)

func screen_shake(amount: float, duration: float) -> void:
    var tw := create_tween()
    tw.tween_method(Callable(self, "_set_camera_offset"), 0.0, amount, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _set_camera_offset(value: float) -> void:
    camera.offset = Vector2(randf_range(-value, value), randf_range(-value, value))
