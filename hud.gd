extends CanvasLayer

@onready var distance_value: Label = $DistanceValue
@onready var shard_value: Label = $ShardValue
@onready var message: Label = $Message

func set_values(distance: int, shards: int) -> void:
    distance_value.text = "%04d m" % distance
    shard_value.text = "%02d" % shards

func show_game_over(distance: int, shards: int) -> void:
    message.text = "RUN OVER\n%04d m    %02d SHARDS\nR TO RESTART" % [distance, shards]
