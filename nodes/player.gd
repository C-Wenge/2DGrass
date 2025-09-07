class_name Player
extends Sprite2D

func _process(delta: float) -> void:
    var velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * 100.0 * delta
    position += velocity
