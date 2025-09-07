@tool
class_name GrassShader
extends Node2D

static var instance: GrassShader = null

@onready var _mask_viewport: SubViewport = $MaskViewport
@onready var _mask_camera: Camera2D = $MaskViewport/MaskCamera

@export var wind_speed := 1.0

@export var direction_noise: NoiseTexture2D:
	set(new_value):
		direction_noise = new_value
		RenderingServer.global_shader_parameter_set("direction_noise", direction_noise)

var _wind_time := 1.0:
	set(new_value):
		_wind_time = new_value
		RenderingServer.global_shader_parameter_set("wind_time", _wind_time)

func _enter_tree() -> void:
	instance = self
	# 监听主视口变化
	get_viewport().size_changed.connect(_update_mask_viewport)

func _exit_tree() -> void:
	# 断开监听
	get_viewport().size_changed.disconnect(_update_mask_viewport)

func _ready() -> void:
	# 设置遮罩纹理
	RenderingServer.global_shader_parameter_set("mask_texture", _mask_viewport.get_texture())

func _process(delta: float) -> void:
	_wind_time += delta * wind_speed

	# 同步相机
	var main_camera: Camera2D = get_viewport().get_camera_2d()
	if is_instance_valid(main_camera):
		_mask_camera.enabled = true
		_mask_camera.global_position = main_camera.global_position
		_mask_camera.zoom = main_camera.zoom
	else:
		_mask_camera.enabled = false

func _update_mask_viewport() -> void:
	# 当主视口发生改变时更新子视口
	_mask_viewport.size = get_viewport().get_visible_rect().size

## 获取视口
func get_mask_viewport() -> SubViewport:
	return _mask_viewport
