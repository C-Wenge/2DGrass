class_name MaskAgent
extends Node2D

@export var _mask_scene: PackedScene

@export var size := Vector2(32.0, 32.0):
    set(new_value):
        size = new_value

        if is_instance_valid(_mask):
            _mask.scale = size / _mask.texture.get_size()

@export_range(0.0, 1.0, 0.001) var radius := 1.0:
    set(new_value):
        radius = new_value

        if is_instance_valid(_mask_material):
            _mask_material.set_shader_parameter("radius", radius)

@export_range(0.0, 1.0, 0.001) var weight := 1.0:
    set(new_value):
        weight = new_value

        if is_instance_valid(_mask_material):
            _mask_material.set_shader_parameter("weight", weight)

@export var bend_curve: CurveTexture:
    set(new_value):
        bend_curve = new_value

        if is_instance_valid(_mask_material):
            _mask_material.set_shader_parameter("bend", bend_curve)

@export var scale_curve: CurveTexture:
    set(new_value):
        scale_curve = new_value

        if is_instance_valid(_mask_material):
            _mask_material.set_shader_parameter("scale", scale_curve)

@export var enable_move := false
@export var start_time := 0.2
@export var duration := 0.0
@export var stop_time := 0.2
@export var detection_distance := 4

var _mask: Sprite2D = null
var _mask_material: ShaderMaterial

var _last_coords: Vector2i
var _state := -1
var _time := 0.0

func _ready() -> void:
    if is_instance_valid(GrassShader.instance):
        _mask = _mask_scene.instantiate()
        _mask_material = _mask.material

        _mask.scale = size / _mask.texture.get_size()
        _mask_material.set_shader_parameter("radius", radius)
        _mask_material.set_shader_parameter("weight", weight)
        _mask_material.set_shader_parameter("bend", bend_curve)
        _mask_material.set_shader_parameter("scale", scale_curve)

        GrassShader.instance.get_mask_viewport().add_child(_mask)

func _process(delta: float) -> void:
    if is_instance_valid(_mask):
        _mask.global_position = global_position

    if not enable_move:
        return

    match _state:
        0:
            weight = clampf(weight + delta / start_time, 0.0, 1.0)
            if weight >= 1.0:
                _state = 1
                _time = duration

        1:
            _time = clampf(_time - delta, 0.0, 1.0)
            if _time <= 0.0:
                _state = 2

        2:
            weight = clampf(weight - delta / stop_time, 0.0, 1.0)
            if weight <= 0.0:
                _state = -1

    var new_coords: Vector2i = Vector2(global_position / Vector2(detection_distance, detection_distance)).floor()

    if new_coords == _last_coords:
        return

    _last_coords = new_coords
    _state = 0
