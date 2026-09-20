extends CanvasLayer

const SCALE: int = 3
const TILE: int = 24
const WIDTH: int = 1152
const HEIGHT: int = 648

func _ready() -> void:
    layer = -10
    add_sky()
    add_strip([8, 9, 10, 11], 282, 16)
    add_strip([12, 13], 354, 16)
    add_strip([14, 15], 432, 16)
    add_fill([22, 23], 504, 10)

func add_sky() -> void:
    var texture: Texture2D = load("res://assets/Tiles/Backgrounds/tile_0000.png")
    var size := TILE * SCALE
    var columns := int(ceil(float(WIDTH) / float(size)))
    var rows := int(ceil(HEIGHT / float(size)))
    for y in range(rows):
        for x in range(columns):
            var sprite := Sprite2D.new()
            sprite.texture = texture
            sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
            sprite.scale = Vector2(SCALE, SCALE)
            sprite.position = Vector2(x * size + size * 0.5, y * size + size * 0.5)
            add_child(sprite)

func add_strip(indices: Array[int], y: int, count: int) -> void:
    var size := TILE * SCALE
    for i in range(count):
        var texture: Texture2D = load("res://assets/Tiles/Backgrounds/tile_%04d.png" % indices[i % indices.size()])
        var sprite := Sprite2D.new()
        sprite.texture = texture
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        sprite.scale = Vector2(SCALE, SCALE)
        sprite.position = Vector2(i * size + size * 0.5, y + size * 0.5)
        add_child(sprite)

func add_fill(indices: Array[int], y: int, rows: int) -> void:
    var size := TILE * SCALE
    var columns := int(ceil(float(WIDTH) / float(size)))
    for row in range(rows):
        for column in range(columns):
            var texture: Texture2D = load("res://assets/Tiles/Backgrounds/tile_%04d.png" % indices[(column + row) % indices.size()])
            var sprite := Sprite2D.new()
            sprite.texture = texture
            sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
            sprite.scale = Vector2(SCALE, SCALE)
            sprite.position = Vector2(column * size + size * 0.5, y + row * size + size * 0.5)
            add_child(sprite)
