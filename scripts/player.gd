extends CharacterBody2D
class_name Player

signal took_damage(current_hp)
signal died
signal ability_unlocked(ability)
signal hit_enemy(enemy)

# Ability bit flags for simple progression
enum Ability { DOUBLE_JUMP = 1, DASH = 2, WALL = 4 }

# Tunable movement values
const MOVE_SPEED := 200.0
const AIR_ACCEL := 18.0
const GROUND_ACCEL := 24.0
const FRICTION := 18.0
const GRAVITY := 1200.0
const JUMP_FORCE := -400.0
const DOUBLE_JUMP_FORCE := -360.0
const MAX_FALL_SPEED := 900.0
const COYOTE_TIME := 0.15
const JUMP_BUFFER := 0.15
const DASH_SPEED := 520.0
const DASH_TIME := 0.14
const DASH_COOLDOWN := 0.5
const INVINCIBLE_DUR := 0.2
const WALL_SLIDE_SPEED := 80.0
const WALL_JUMP_FORCE := Vector2(-260, -360)
const MAX_HP := 5

# Visual colors
const COLOR_BODY := Color(0, 0, 0)
const COLOR_EYE := Color(1, 1, 1)

@onready var sprite: Node2D = $Visual
@onready var eyes: Node2D = $Visual/Eyes
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var buffer_timer: Timer = $JumpBufferTimer
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldown
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var attack_area: Area2D = $AttackArea
@onready var attack_hitbox: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var jump_dust: GPUParticles2D = $JumpDust
@onready var land_dust: GPUParticles2D = $LandDust

var unlocked := 0
var hp := MAX_HP
var jump_count := 0
var buffered_jump := false
var is_dashing := false
var dash_dir := 0
var facing := 1
var invincible := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    update_visual()
    attack_area.monitoring = false

func _physics_process(delta: float) -> void:
    handle_input()
    apply_gravity(delta)
    apply_horizontal(delta)
    handle_wall_slide()
    handle_jump_buffer()
    handle_dash(delta)
    move_and_slide()
    handle_landing()
    update_attack_position()

func handle_input() -> void:
    var input_dir := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    if input_dir != 0:
        facing = sign(input_dir)
    if not is_dashing:
        velocity.x = lerp(velocity.x, input_dir * MOVE_SPEED, (GROUND_ACCEL if is_on_floor() else AIR_ACCEL) * get_physics_process_delta_time())
        if input_dir == 0 and is_on_floor():
            velocity.x = lerp(velocity.x, 0.0, FRICTION * get_physics_process_delta_time())

    if Input.is_action_just_pressed("jump"):
        buffered_jump = true
        buffer_timer.start(JUMP_BUFFER)

    if Input.is_action_just_pressed("attack"):
        perform_attack()

    if Input.is_action_just_pressed("dash") and has_ability(Ability.DASH):
        try_dash()

func apply_gravity(delta: float) -> void:
    if is_dashing:
        return
    var gravity := GRAVITY
    if velocity.y < 0 and Input.is_action_pressed("jump"):
        gravity *= 0.6
    velocity.y = clamp(velocity.y + gravity * delta, -INF, MAX_FALL_SPEED)

func handle_jump_buffer() -> void:
    if buffered_jump:
        if can_jump():
            do_jump()
            buffered_jump = false
            buffer_timer.stop()

func can_jump() -> bool:
    return is_on_floor() or coyote_timer.time_left > 0.0 or (has_ability(Ability.DOUBLE_JUMP) and jump_count < 2) or (has_ability(Ability.WALL) and is_on_wall())

func do_jump() -> void:
    if is_on_wall() and has_ability(Ability.WALL) and not is_on_floor():
        velocity = Vector2(WALL_JUMP_FORCE.x * -facing, WALL_JUMP_FORCE.y)
        facing *= -1
    elif is_on_floor() or coyote_timer.time_left > 0.0:
        velocity.y = JUMP_FORCE
        jump_dust.emitting = true
    elif has_ability(Ability.DOUBLE_JUMP) and jump_count < 2:
        velocity.y = DOUBLE_JUMP_FORCE
    jump_count += 1

func handle_wall_slide() -> void:
    if has_ability(Ability.WALL) and is_on_wall_only() and velocity.y > 0:
        velocity.y = min(velocity.y, WALL_SLIDE_SPEED)

func handle_dash(delta: float) -> void:
    if is_dashing:
        velocity = Vector2(dash_dir * DASH_SPEED, 0)
        if dash_timer.time_left == 0:
            is_dashing = false
    else:
        if dash_cooldown_timer.time_left == 0:
            dash_dir = facing

func handle_landing() -> void:
    if is_on_floor():
        if not coyote_timer.is_stopped():
            land_dust.emitting = true
        jump_count = 0
        coyote_timer.start(COYOTE_TIME)

func try_dash() -> void:
    if dash_cooldown_timer.time_left > 0 or is_dashing:
        return
    is_dashing = true
    invincible = true
    dash_timer.start(DASH_TIME)
    dash_cooldown_timer.start(DASH_COOLDOWN)
    invincible_timer.start(INVINCIBLE_DUR)

func apply_horizontal(delta: float) -> void:
    if is_on_floor():
        coyote_timer.start(COYOTE_TIME)

func _on_CoyoteTimer_timeout() -> void:
    pass

func _on_JumpBufferTimer_timeout() -> void:
    buffered_jump = false

func _on_DashTimer_timeout() -> void:
    is_dashing = false

func _on_InvincibleTimer_timeout() -> void:
    invincible = false

func _on_AttackArea_body_entered(body: Node) -> void:
    if body.has_method("take_hit"):
        body.take_hit(facing)
        emit_signal("hit_enemy", body)

func perform_attack() -> void:
    attack_area.monitoring = true
    $AttackFlash.play()
    await get_tree().create_timer(0.1).timeout
    attack_area.monitoring = false

func update_attack_position() -> void:
    attack_area.position.x = 16 * facing
    attack_hitbox.position.x = 8 * facing

func take_damage(amount: int) -> void:
    if invincible:
        return
    hp -= amount
    emit_signal("took_damage", hp)
    invincible = true
    invincible_timer.start(INVINCIBLE_DUR)
    if hp <= 0:
        emit_signal("died")

func has_ability(bit: int) -> bool:
    return unlocked & bit != 0

func grant_ability(bit: int) -> void:
    unlocked |= bit
    emit_signal("ability_unlocked", bit)

func update_visual() -> void:
    # Body and eyes are simple shapes; here to remind colors if tweaked later
    $Visual.modulate = COLOR_BODY
    for eye in eyes.get_children():
        eye.modulate = COLOR_EYE
