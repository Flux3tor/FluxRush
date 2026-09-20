extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var world: Node2D = $World
@onready var hud: CanvasLayer = $HUD

var best: int = 0
var game_over: bool = false
var started: bool = false
var loading: bool = false
var menu_layer: CanvasLayer
var menu_root: Control
var loading_root: Control
var loading_shard: Sprite2D

func _ready() -> void:
    player.player_died.connect(_on_player_died)
    world.shard_picked.connect(_refresh_hud)
    hud.visible = false
    player.set_physics_process(false)
    world.set_process(false)
    _build_menu()

func _process(_delta: float) -> void:
    if not started:
        if loading and is_instance_valid(loading_shard):
            loading_shard.position.y = sin(Time.get_ticks_msec() * 0.004) * 6.0
        return

    if Input.is_action_just_pressed("restart") and game_over:
        _restart_run()
        return

    if game_over:
        return

    _refresh_hud()

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER) and not started and not loading:
            _start_run()

func _build_menu() -> void:
    menu_layer = CanvasLayer.new()
    menu_layer.layer = 20
    menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(menu_layer)

    menu_root = Control.new()
    menu_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    menu_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    menu_layer.add_child(menu_root)

    var shade := ColorRect.new()
    shade.color = Color(0.02, 0.03, 0.035, 0.68)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    menu_root.add_child(shade)

    var title := Label.new()
    title.text = "FluxRush"
    title.add_theme_font_size_override("font_size", 38)
    title.add_theme_color_override("font_color", Color("#f0eee5"))
    title.position = Vector2(64, 54)
    title.size = Vector2(360, 48)
    menu_root.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "endless platform run"
    subtitle.add_theme_font_size_override("font_size", 14)
    subtitle.add_theme_color_override("font_color", Color("#c7cecb"))
    subtitle.position = Vector2(67, 101)
    subtitle.size = Vector2(300, 24)
    menu_root.add_child(subtitle)

    var controls := Label.new()
    controls.text = "A / D  move     Space  jump     Shift  dash"
    controls.add_theme_font_size_override("font_size", 13)
    controls.add_theme_color_override("font_color", Color("#d9dfdc"))
    controls.position = Vector2(67, 150)
    controls.size = Vector2(520, 24)
    menu_root.add_child(controls)

    var prompt := Label.new()
    prompt.text = "Press Enter to start"
    prompt.add_theme_font_size_override("font_size", 17)
    prompt.add_theme_color_override("font_color", Color("#f0eee5"))
    prompt.position = Vector2(67, 566)
    prompt.size = Vector2(300, 26)
    menu_root.add_child(prompt)

func _start_run() -> void:
    if loading or started:
        return
    loading = true
    menu_root.visible = false
    _show_loading()
    var timer := get_tree().create_timer(1.35)
    timer.timeout.connect(_finish_loading)

func _show_loading() -> void:
    loading_root = Control.new()
    loading_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    loading_root.process_mode = Node.PROCESS_MODE_ALWAYS
    menu_layer.add_child(loading_root)

    var shade := ColorRect.new()
    shade.color = Color(0.02, 0.03, 0.035, 0.68)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    loading_root.add_child(shade)

    var title := Label.new()
    title.text = "Get ready"
    title.add_theme_font_size_override("font_size", 28)
    title.add_theme_color_override("font_color", Color("#f0eee5"))
    title.position = Vector2(64, 84)
    title.size = Vector2(300, 38)
    loading_root.add_child(title)

    var instructions := Label.new()
    instructions.text = "A / D  move     Space  jump     Shift  dash"
    instructions.add_theme_font_size_override("font_size", 13)
    instructions.add_theme_color_override("font_color", Color("#d9dfdc"))
    instructions.position = Vector2(67, 132)
    instructions.size = Vector2(520, 24)
    loading_root.add_child(instructions)

    loading_shard = Sprite2D.new()
    loading_shard.texture = load("res://assets/Tiles/tile_0008.png")
    loading_shard.scale = Vector2(2.6, 2.6)
    loading_shard.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    loading_shard.position = Vector2(576, 330)
    loading_root.add_child(loading_shard)

    var status := Label.new()
    status.text = "starting run..."
    status.add_theme_font_size_override("font_size", 12)
    status.add_theme_color_override("font_color", Color("#aeb9b5"))
    status.position = Vector2(67, 590)
    status.size = Vector2(260, 20)
    loading_root.add_child(status)

func _finish_loading() -> void:
    loading = false
    started = true
    if is_instance_valid(loading_root):
        loading_root.queue_free()
    hud.visible = true
    player.set_physics_process(true)
    world.set_process(true)
    _refresh_hud()

func _refresh_hud() -> void:
    if not is_instance_valid(player):
        return
    var distance: int = maxi(0, int((player.global_position.x - 220.0) / 10.0))
    hud.set_values(distance, world.shard_count)

func _restart_run() -> void:
    get_tree().reload_current_scene()

func _on_player_died() -> void:
    game_over = true
    var distance: int = maxi(0, int((player.global_position.x - 220.0) / 10.0))
    best = maxi(best, distance)
    hud.show_game_over(distance, world.shard_count)
