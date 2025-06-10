extends CanvasLayer

signal next_level_pressed
signal menu_pressed
@onready var next_button = $Panel/VBoxContainer/ButtonNext
@onready var menu_button = $Panel/VBoxContainer/ButtonMenu
	
func _ready():
	# Показываем текст победы
	_show_victory_text()
	# Анимация появления
	$Panel.modulate.a = 0
	var tween = create_tween()
	tween.tween_property($Panel, "modulate:a", 1.0, 0.3)
	# Устанавливаем режим мыши для UI
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Устанавливаем фокус на кнопку "Next"
	set_next_button_focus()
	# Подключаем сигналы кнопок (если не подключены в редакторе)

	if next_button is Button:
		if not next_button.is_connected("pressed", Callable(self, "_on_button_next_pressed")):
			next_button.connect("pressed", Callable(self, "_on_button_next_pressed"))
		if not next_button.is_connected("focus_entered", Callable(self, "_on_button_focused").bind(next_button)):
			next_button.connect("focus_entered", Callable(self, "_on_button_focused").bind(next_button))
	if menu_button and menu_button is Button:
		if not menu_button.is_connected("pressed", Callable(self, "_on_button_menu_pressed")):
			menu_button.connect("pressed", Callable(self, "_on_button_menu_pressed"))
		if not menu_button.is_connected("focus_entered", Callable(self, "_on_button_focused").bind(menu_button)):
			menu_button.connect("focus_entered", Callable(self, "_on_button_focused").bind(menu_button))

func set_next_button_focus():
	if next_button is Button:
		next_button.grab_focus()
		print("Focus set to ButtonNext")
	else:
		print("ButtonNext not found or not a Button")

func _on_button_next_pressed() -> void:
	print("Next button pressed")
	next_level_pressed.emit()
	var tween = create_tween()
	tween.tween_property($Panel, "modulate:a", 0.0, 0.3)
	tween.tween_callback(Callable(self, "queue_free"))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_button_menu_pressed() -> void:
	print("Menu button pressed")
	menu_pressed.emit()
	var tween = create_tween()
	tween.tween_property($Panel, "modulate:a", 0.0, 0.3)
	tween.tween_callback(Callable(self, "queue_free"))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_button_focused(button: Button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

func open_dialog():
	visible = true
	_show_victory_text()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_next_button_focus()

func _show_victory_text() -> void:
	var score = Global.get_current_layer() if Global.has_method("get_current_layer") else 0
	$Panel/Title.text = "🏆 ПОБЕДА! СЧЁТ: " + str(score) + " 🏆"
