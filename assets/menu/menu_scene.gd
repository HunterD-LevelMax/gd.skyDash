extends Node3D

@export var level_scene_path: String = "res://assets/levels/level_1/level_1.tscn"
@onready var exit_dialog = preload("res://assets/ui/exit_dialog.tscn")
@onready var record_text = $Record_Label
@onready var coins_text = $Coins_Label

var is_player_in_exit_area: bool = false  # Флаг нахождения игрока в зоне
var dialog_instance: CanvasLayer = null  # Экземпляр диалога для управления

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("Сцена старта загружена. Путь к уровню: ", level_scene_path)
	
	if not ResourceLoader.exists(level_scene_path):
		push_warning("Сцена уровня не найдена по пути: ", level_scene_path)
		
	_load_data()
	
func _on_start_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		var fade: ColorRect = ColorRect.new()
		fade.color = Color(0, 0, 0, 0)
		fade.size = get_viewport().get_visible_rect().size
		add_child(fade)
		
		var tween: Tween = create_tween()
		tween.tween_property(fade, "color:a", 1.0, 0.5)
		tween.tween_callback(func():
			var level_scene: PackedScene = load(level_scene_path) as PackedScene
			if level_scene:
				get_tree().change_scene_to_packed(level_scene)
			else:
				push_error("Не удалось загрузить сцену уровня")
				fade.queue_free())

func _on_exit_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_player_in_exit_area:
		is_player_in_exit_area = true
		_show_exit_dialog()

func _on_exit_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		is_player_in_exit_area = false
		# Закрываем диалог, если он открыт
		if dialog_instance:
			dialog_instance._on_cancel_pressed()  # Вызываем отмену, чтобы вернуть MOUSE_MODE_CAPTURED
			dialog_instance = null

func _show_exit_dialog() -> void:
	if dialog_instance:
		return  # Предотвращаем повторное открытие
	dialog_instance = exit_dialog.instantiate()
	add_child(dialog_instance)
	dialog_instance.open_dialog()
	dialog_instance.exit_confirmed.connect(_on_exit_confirmed)
	dialog_instance.exit_cancelled.connect(_on_exit_cancelled)

func _on_exit_confirmed():
	get_tree().quit()

func _on_exit_cancelled():
	is_player_in_exit_area = false  # Сбрасываем флаг при отмене
	if dialog_instance:
		dialog_instance.queue_free()
		dialog_instance = null
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_reset_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.position = $Spawn.position + Vector3(0, 1.0, 0)
		body.show_floating_text("Упсс!", 2.0)

func _load_data() -> void:
	var record = Global.load_best_score()
	
	if record is int and record == 0:
		record_text.text = "🌟 РЕКОРД ЕЩЕ НЕ УСТАНОВЛЕН 🌟"
	else:
		record_text.text = "🌟 МОЙ РЕКОРД: " + str(record) + " 🌟"
	print("рекорд вызван: ", record)
	
	var all_coins = Global.load_coins()
	
	if all_coins is int:
		coins_text.text = "Мое сокровище! МОНЕТ:" + str(all_coins) + " 🟡"
	else:
		record_text.text = "Надо собрать монеты"
	print("всего монет вызван: ", all_coins)	
	
	
	
	
	
