extends Node3D

@export var jump_boost: float = 1.25  # Множитель прыжка
@export var boost_duration: float = 10.0  # Длительность бонуса
@export var rotation_speed: float = 2.0  # Скорость вращения в радианах/секунду
@export var jump_height: float = 1.0  # Высота подпрыгивания бонуса
@export var jump_duration: float = 0.15  # Время подпрыгивания
@export var fade_duration: float = 0.3  # Время затухания

@onready var jump_audio: AudioStreamPlayer = $JumpSound  # Звук сбора бонуса
@onready var bonus_area: Area3D = $Area3D  # Зона столкновения бонуса

var collected: bool = false  # Флаг, указывающий, собран ли бонус
var original_position: Vector3  # Исходная позиция бонуса

# Инициализация бонуса
func _ready() -> void:
	original_position = position
	jump_audio.finished.connect(_on_jump_audio_finished)

# Обработка вращения бонуса
func _process(delta: float) -> void:
	if not collected:
		rotate_y(rotation_speed * delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name != "Player" or collected:
		return
		
	collected = true
	body.apply_jump_bonus(jump_boost, boost_duration)
	print("Бонус прыжка собран")
		
	# Отключаем столкновения
	bonus_area.set_deferred("monitoring", false)
	bonus_area.set_deferred("monitorable", false)
	
	# Останавливаем вращение
	set_process(false)
	
	# Анимация подпрыгивания и затухания
	var jump_up = original_position + Vector3(0, jump_height, 0)
	var tween = create_tween()
	tween.tween_property(self, "position", jump_up, jump_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", original_position, jump_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		if jump_audio.stream:
			jump_audio.play()
		else:
			_on_jump_audio_finished()
	)

# Удаление бонуса после окончания звука
func _on_jump_audio_finished() -> void:
	queue_free()
