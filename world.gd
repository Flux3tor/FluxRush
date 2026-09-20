extends Node2D

const TILE_SIZE: float = 54.0
const PLATFORM_TOP: float = 540.0
const CHUNK_WIDTH: float = TILE_SIZE * 18.0
const LOOKAHEAD: float = 2160.0

var rng := RandomNumberGenerator.new()
var next_chunk_x: float = 0.0
var chunks: Array[Node2D] = []
var generated_count: int = 0
var player: CharacterBody2D
var shard_count: int = 0

var ground_textures: Array[Texture2D] = []
var shard_texture: Texture2D
var spike_texture: Texture2D
var digit_textures: Dictionary = {}

signal shard_picked

func _ready() -> void:
    rng.seed = Time.get_ticks_usec()
    player = get_parent().get_node("Player")
    ground_textures = [
        load("res://assets/Tiles/tile_0000.png"),
        load("res://assets/Tiles/tile_0001.png"),
        load("res://assets/Tiles/tile_0002.png"),
        load("res://assets/Tiles/tile_0003.png")
    ]
    shard_texture = load("res://assets/Tiles/tile_0008.png")
    spike_texture = load("res://assets/Tiles/tile_0068.png")
    for i in range(10):
        digit_textures[i] = load("res://assets/Tiles/tile_%04d.png" % (170 + i))
    for i in range(4):
        generate_chunk(rng.randi_range(0, 5))

func _process(_delta: float) -> void:
    if not is_instance_valid(player):
        return
    while next_chunk_x < player.global_position.x + LOOKAHEAD:
        var difficulty: int = clampi(int(player.global_position.x / 2700.0), 0, 5)
        generate_chunk(difficulty)
    for chunk in chunks.duplicate():
        if is_instance_valid(chunk) and chunk.position.x < player.global_position.x - 1800.0:
            chunks.erase(chunk)
            chunk.queue_free()

func generate_chunk(difficulty: int) -> void:
    var chunk := Node2D.new()
    chunk.position.x = next_chunk_x
    add_child(chunk)
    chunks.append(chunk)
    generated_count += 1

    var roll := rng.randi_range(0, 7)
    if roll == 0:
        make_flat(chunk)
    elif roll == 1:
        make_stair_up(chunk)
    elif roll == 2:
        make_gap_bridge(chunk)
    elif roll == 3:
        make_stair_down(chunk)
    elif roll == 4:
        make_double_gap(chunk)
    elif roll == 5:
        make_upper_route(chunk)
    elif roll == 6:
        make_spike_steps(chunk)
    else:
        make_combo(chunk)

    next_chunk_x += CHUNK_WIDTH

func make_flat(chunk: Node2D) -> void:
    platform(chunk, 0, PLATFORM_TOP, 18)
    spawn_shards_on_platform(chunk, 5, PLATFORM_TOP, 4)

func make_stair_up(chunk: Node2D) -> void:
    platform(chunk, 0, PLATFORM_TOP, 4)
    platform(chunk, 4, PLATFORM_TOP - TILE_SIZE, 4)
    platform(chunk, 8, PLATFORM_TOP - TILE_SIZE * 2.0, 4)
    platform(chunk, 12, PLATFORM_TOP - TILE_SIZE, 3)
    platform(chunk, 15, PLATFORM_TOP, 3)
    spawn_shards_on_platform(chunk, 4, PLATFORM_TOP - TILE_SIZE, 3)
    spawn_shards_on_platform(chunk, 8, PLATFORM_TOP - TILE_SIZE * 2.0, 3)

func make_stair_down(chunk: Node2D) -> void:
    platform(chunk, 0, PLATFORM_TOP, 3)
    platform(chunk, 3, PLATFORM_TOP - TILE_SIZE * 2.0, 4)
    platform(chunk, 7, PLATFORM_TOP - TILE_SIZE, 4)
    platform(chunk, 11, PLATFORM_TOP - TILE_SIZE * 2.0, 4)
    platform(chunk, 15, PLATFORM_TOP, 3)
    spawn_shards_on_platform(chunk, 3, PLATFORM_TOP - TILE_SIZE * 2.0, 3)
    spawn_shards_on_platform(chunk, 11, PLATFORM_TOP - TILE_SIZE * 2.0, 3)

func make_gap_bridge(chunk: Node2D) -> void:
    platform(chunk, 0, PLATFORM_TOP, 5)
    platform(chunk, 5, PLATFORM_TOP - TILE_SIZE, 3)
    platform(chunk, 10, PLATFORM_TOP - TILE_SIZE, 3)
    platform(chunk, 13, PLATFORM_TOP, 5)
    spawn_shards_on_platform(chunk, 5, PLATFORM_TOP - TILE_SIZE, 3)
    spawn_spikes(chunk, 13, PLATFORM_TOP, 1)

func make_double_gap(chunk: Node2D) -> void:
    platform(chunk, 0, PLATFORM_TOP, 4)
    platform(chunk, 5, PLATFORM_TOP - TILE_SIZE, 3)
    platform(chunk, 10, PLATFORM_TOP - TILE_SIZE * 2.0, 3)
    platform(chunk, 14, PLATFORM_TOP - TILE_SIZE, 4)
    spawn_shards_on_platform(chunk, 5, PLATFORM_TOP - TILE_SIZE, 3)
    spawn_shards_on_platform(chunk, 10, PLATFORM_TOP - TILE_SIZE * 2.0, 3)
    spawn_spikes(chunk, 15, PLATFORM_TOP - TILE_SIZE, 1)

func make_upper_route(chunk: Node2D) -> void:
    platform(chunk, 0, PLATFORM_TOP, 4)
    platform(chunk, 4, PLATFORM_TOP - TILE_SIZE * 2.0, 6)
    platform(chunk, 11, PLATFORM_TOP - TILE_SIZE * 2.0, 4)
    platform(chunk, 15, PLATFORM_TOP, 3)
    spawn_spikes(chunk, 1, PLATFORM_TOP, 1)
    spawn_shards_on_platform(chunk, 4, PLATFORM_TOP - TILE_SIZE * 2.0, 5)
    spawn_shards_on_platform(chunk, 11, PLATFORM_TOP - TILE_SIZE * 2.0, 3)

func make_spike_steps(chunk: Node2D) -> void:
    platform(chunk, 0, PLATFORM_TOP, 5)
    platform(chunk, 5, PLATFORM_TOP - TILE_SIZE, 5)
    platform(chunk, 10, PLATFORM_TOP, 4)
    platform(chunk, 14, PLATFORM_TOP - TILE_SIZE, 4)
    spawn_spikes(chunk, 2, PLATFORM_TOP, 1)
    spawn_spikes(chunk, 7, PLATFORM_TOP - TILE_SIZE, 2)
    spawn_spikes(chunk, 11, PLATFORM_TOP, 1)
    spawn_shards_on_platform(chunk, 14, PLATFORM_TOP - TILE_SIZE, 3)

func make_combo(chunk: Node2D) -> void:
    platform(chunk, 0, PLATFORM_TOP, 4)
    platform(chunk, 4, PLATFORM_TOP - TILE_SIZE * 2.0, 4)
    platform(chunk, 9, PLATFORM_TOP - TILE_SIZE, 3)
    platform(chunk, 13, PLATFORM_TOP - TILE_SIZE * 2.0, 3)
    platform(chunk, 16, PLATFORM_TOP, 2)
    spawn_spikes(chunk, 1, PLATFORM_TOP, 1)
    spawn_spikes(chunk, 6, PLATFORM_TOP - TILE_SIZE * 2.0, 1)
    spawn_spikes(chunk, 10, PLATFORM_TOP - TILE_SIZE, 1)
    spawn_shards_on_platform(chunk, 4, PLATFORM_TOP - TILE_SIZE * 2.0, 3)
    spawn_shards_on_platform(chunk, 13, PLATFORM_TOP - TILE_SIZE * 2.0, 2)

func platform(parent: Node2D, tile_x: int, top_y: float, length: int) -> void:
    if length < 1:
        return
    var body := StaticBody2D.new()
    body.position = Vector2((tile_x + length * 0.5) * TILE_SIZE, top_y + TILE_SIZE * 0.5)
    body.collision_layer = 1
    body.collision_mask = 0
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = Vector2(length * TILE_SIZE, TILE_SIZE)
    collision.shape = shape
    body.add_child(collision)
    parent.add_child(body)
    for i in range(length):
        var sprite := Sprite2D.new()
        if length == 1:
            sprite.texture = ground_textures[0]
        elif i == 0:
            sprite.texture = ground_textures[0]
        elif i == length - 1:
            sprite.texture = ground_textures[3]
        else:
            sprite.texture = ground_textures[1 + (i % 2)]
        sprite.scale = Vector2(3.0, 3.0)
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        sprite.position = Vector2((tile_x + i) * TILE_SIZE + TILE_SIZE * 0.5, top_y + TILE_SIZE * 0.5)
        parent.add_child(sprite)

func spawn_spikes(parent: Node2D, tile_x: int, top_y: float, amount: int) -> void:
    for i in range(amount):
        var spike := Area2D.new()
        spike.position = Vector2((tile_x + i + 0.5) * TILE_SIZE, top_y - 27.0)
        spike.collision_layer = 0
        spike.collision_mask = 1
        var collision := CollisionShape2D.new()
        var shape := RectangleShape2D.new()
        shape.size = Vector2(44.0, 24.0)
        collision.position.y = 9.0
        collision.shape = shape
        spike.add_child(collision)
        var sprite := Sprite2D.new()
        sprite.texture = spike_texture
        sprite.scale = Vector2(3.0, 3.0)
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        spike.add_child(sprite)
        spike.body_entered.connect(_on_hazard_body.bind(spike))
        parent.add_child(spike)

func spawn_shards_on_platform(parent: Node2D, tile_x: int, top_y: float, amount: int) -> void:
    for i in range(amount):
        var shard := Area2D.new()
        shard.position = Vector2((tile_x + i + 0.5) * TILE_SIZE, top_y - 34.0)
        shard.collision_layer = 0
        shard.collision_mask = 1
        var collision := CollisionShape2D.new()
        var shape := CircleShape2D.new()
        shape.radius = 16.0
        collision.shape = shape
        shard.add_child(collision)
        var sprite := Sprite2D.new()
        sprite.texture = shard_texture
        sprite.scale = Vector2(2.4, 2.4)
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        shard.add_child(sprite)
        var base_y: float = shard.position.y
        var phase: float = float(i) * 0.22
        var tween := shard.create_tween().set_loops()
        tween.tween_interval(phase)
        tween.tween_property(shard, "position:y", base_y - 7.0, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        tween.tween_property(shard, "position:y", base_y, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        shard.body_entered.connect(_on_shard_body.bind(shard))
        parent.add_child(shard)

func _on_shard_body(body: Node, shard: Area2D) -> void:
    if body == player and is_instance_valid(shard):
        shard_count += 1
        spawn_score_popup(shard.global_position, shard_count)
        shard_picked.emit()
        shard.queue_free()

func spawn_score_popup(position: Vector2, value: int) -> void:
    var popup := Node2D.new()
    popup.position = position + Vector2(0, -12)
    add_child(popup)
    var digits := str(value)
    var width: float = digits.length() * 24.0
    for i in range(digits.length()):
        var digit := Sprite2D.new()
        digit.texture = digit_textures[int(digits[i])]
        digit.scale = Vector2(1.35, 1.35)
        digit.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        digit.position.x = float(i) * 24.0 - width * 0.5 + 12.0
        popup.add_child(digit)
    var tween := popup.create_tween()
    tween.tween_property(popup, "position:y", popup.position.y - 22.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(popup, "position:y", popup.position.y - 10.0, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_interval(0.08)
    tween.tween_callback(popup.queue_free)

func _on_hazard_body(body: Node, hazard: Area2D) -> void:
    if body == player and is_instance_valid(hazard) and player.has_method("die"):
        player.die()
