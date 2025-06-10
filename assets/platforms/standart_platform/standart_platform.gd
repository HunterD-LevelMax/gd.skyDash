extends Node3D

signal platform_destroyed

const SIZE_A = Vector3(1.2, 0.4, 1.9)  # Размеры tile_blue в обычном состоянии
const SIZE_B = Vector3(1.0, 0.4, 1.7)  # Размеры tile_blue при сжатии

var is_blinking = false
var blink_time_total = 3.0  # Общее время пульсации
var blink_timer = 0.0
var base_pulse_speed = 1.5
var max_pulse_speed = 4.0

@onready var tile_blue: MeshInstance3D = $StaticBody3D/tile_blue

func _ready():
	tile_blue.scale = SIZE_A  # Устанавливаем начальный размер меша

func _process(delta: float) -> void:
	if is_blinking:
		blink_timer += delta
		
		# Увеличиваем скорость пульсации
		var time_ratio = blink_timer / blink_time_total
		var pulse_speed = lerp(base_pulse_speed, max_pulse_speed, time_ratio * time_ratio)
		
		# Пульсация меша (не родительской ноды!)
		var pulse_factor = (sin(blink_timer * PI * pulse_speed) + 1) / 2
		tile_blue.scale = SIZE_A.lerp(SIZE_B, pulse_factor)
		
		if blink_timer >= blink_time_total:
			set_process(false)
			emit_signal("platform_destroyed")
			hide_platform()

func hide_platform() -> void:
	visible = false
	is_blinking = false
	tile_blue.scale = SIZE_A  # Восстанавливаем размер меша
	queue_free_parent()  # Убираем платформу из сцены

func queue_free_parent() -> void:
	if get_parent():
		get_parent().remove_child(self)  # Удаляем платформу из родительской сцены

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_blinking:
		is_blinking = true
		blink_timer = 0.0
		set_process(true)
