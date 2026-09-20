extends CharacterBody2D

const GRAVITY: float = 1500.0
const JUMP_VELOCITY: float = -590.0
const START_SPEED: float = 330.0
const MAX_SPEED: float = 470.0
const ACCEL: float = 1100.0
const AIR_ACCEL: float = 700.0
const DASH_SPEED: float = 820.0
const DASH_TIME: float = 0.12

var sprite: Sprite2D
var cam: Camera2D
var run_frames: Array[Texture2D] = []
var anim_clock: float = 0.0
var dash_left: float = 0.0
var dash_available: bool = true
var alive: bool = true
var coyote_time: float = 0.0
var was_on_floor: bool = false

signal player_died

func _ready() -> void:
    setup_inputs()

    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = Vector2(48.0, 48.0)
    collision.shape = shape
    collision.position = Vector2(0, 0)
    add_child(collision)

    run_frames = [
        load("res://assets/Tiles/Characters/tile_0011.png"),
        load("res://assets/Tiles/Characters/tile_0012.png")
    ]
    sprite = Sprite2D.new()
    sprite.texture = run_frames[0]
    sprite.scale = Vector2(3.0, 3.0)
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    add_child(sprite)

    cam = Camera2D.new()
    cam.position = Vector2(260, -35)
    cam.position_smoothing_enabled = true
    cam.position_smoothing_speed = 8.0
    cam.limit_left = 0
    cam.limit_top = 0
    cam.limit_bottom = 648
    add_child(cam)

func _physics_process(delta: float) -> void:
    if not alive:
        return
    if global_position.y > 760.0:
        die()
        return

    var input_x: float = Input.get_axis("move_left", "move_right")
    var target_speed: float = START_SPEED + input_x * 120.0
    if is_zero_approx(input_x):
        target_speed = START_SPEED
    var accel: float = ACCEL if is_on_floor() else AIR_ACCEL
    velocity.x = move_toward(velocity.x, target_speed, accel * delta)
    velocity.x = clampf(velocity.x, 180.0, MAX_SPEED)

    if not is_on_floor():
        velocity.y += GRAVITY * delta
    else:
        velocity.y = minf(velocity.y, 30.0)
        dash_available = true

    if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_time > 0.0):
        velocity.y = JUMP_VELOCITY
        coyote_time = 0.0
        dash_available = true

    if Input.is_action_just_pressed("dash") and dash_available and dash_left <= 0.0:
        dash_left = DASH_TIME
        dash_available = false
        velocity.x = DASH_SPEED
        velocity.y = 0.0

    if dash_left > 0.0:
        dash_left -= delta
        velocity.x = DASH_SPEED
        velocity.y = 0.0

    coyote_time = maxf(0.0, coyote_time - delta)
    if was_on_floor and not is_on_floor():
        coyote_time = 0.10
    was_on_floor = is_on_floor()

    move_and_slide()

    anim_clock += delta
    if is_on_floor() and absf(velocity.x) > 200.0:
        sprite.texture = run_frames[int(anim_clock * 8.0) % run_frames.size()]
    else:
        sprite.texture = run_frames[0]

func setup_inputs() -> void:
    add_key_action("move_left", KEY_A)
    add_key_action("move_left", KEY_LEFT)
    add_key_action("move_right", KEY_D)
    add_key_action("move_right", KEY_RIGHT)
    add_key_action("jump", KEY_SPACE)
    add_key_action("jump", KEY_W)
    add_key_action("jump", KEY_UP)
    add_key_action("dash", KEY_SHIFT)
    add_key_action("dash", KEY_E)
    add_key_action("restart", KEY_R)

func add_key_action(action: StringName, keycode: Key) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    var event := InputEventKey.new()
    event.physical_keycode = keycode
    if not InputMap.action_has_event(action, event):
        InputMap.action_add_event(action, event)

func die() -> void:
    if not alive:
        return
    alive = false
    player_died.emit()
