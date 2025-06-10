extends Node3D

# Настройки вращения
@export var mouse_sensitivity: float = 0.005
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") 
var min_vertical_angle: float = deg_to_rad(-60)
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") 
var max_vertical_angle: float = deg_to_rad(60)
@export var gamepad_sensitivity: float = 3.0  # Чувствительность геймпада

# Настройки зума
@export var zoom_speed: float = 1.0
@export var min_spring_length: float = 1.0
@export var max_spring_length: float = 10.0
@export var zoom_interpolation_speed: float = 5.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
var player: CharacterBody3D  # Ссылка на игрока для доступа к настройкам геймпада

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Находим игрока
	player = get_parent() if get_parent() is CharacterBody3D else null
	if not player:
		print("Ошибка: Игрок не найден в родительском узле")

func _unhandled_input(event: InputEvent) -> void:
	# Вращение камеры мышью
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.y = wrapf(rotation.y, -TAU, TAU)
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x, min_vertical_angle, max_vertical_angle)
	
	# Зум колесиком мыши или бамперами геймпада
	if event.is_action_pressed("wheel_up"):
		spring_arm.spring_length = clamp(
			spring_arm.spring_length - zoom_speed, 
			min_spring_length, 
			max_spring_length
		)
	if event.is_action_pressed("wheel_down"):
		spring_arm.spring_length = clamp(
			spring_arm.spring_length + zoom_speed, 
			min_spring_length, 
			max_spring_length
		)
	
	# Переключение режима мыши
	if event.is_action_pressed("toggle_mouse_captured"):
		match Input.mouse_mode:
			Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			_:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	# Вращение камеры геймпадом
	if player and Input.get_connected_joypads().size() > 0:
		var camera_input: Vector2 = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
		if camera_input.length():
			rotation.y -= camera_input.x * gamepad_sensitivity * delta
			rotation.y = wrapf(rotation.y, -TAU, TAU)
			rotation.x -= camera_input.y * gamepad_sensitivity * delta
			rotation.x = clamp(rotation.x, min_vertical_angle, max_vertical_angle)
	
	# Плавное обновление зума
	spring_arm.spring_length = lerp(
		spring_arm.spring_length,
		clamp(spring_arm.spring_length, min_spring_length, max_spring_length),
		zoom_interpolation_speed * delta
	)
