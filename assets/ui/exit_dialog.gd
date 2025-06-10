extends CanvasLayer

signal exit_confirmed
signal exit_cancelled

@onready var confirm_button = $Panel/VBoxContainer/ButtonConfirm
@onready var cancel_button = $Panel/VBoxContainer/ButtonCancel

func _ready():
	# Скрываем панель изначально
	$Panel.modulate.a = 0
	var tween = create_tween()
	tween.tween_property($Panel, "modulate:a", 1.0, 0.3)
	# Устанавливаем режим мыши для UI
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Устанавливаем фокус на кнопку "Подтвердить"
	set_cancel_button_focus()
	# Подключаем сигналы кнопок (если не подключены в редакторе)

	if confirm_button is Button:
		if not confirm_button.is_connected("pressed", Callable(self, "_on_confirm_pressed")):
			confirm_button.connect("pressed", Callable(self, "_on_confirm_pressed"))
		if not confirm_button.is_connected("focus_entered", Callable(self, "_on_button_focused").bind(confirm_button)):
			confirm_button.connect("focus_entered", Callable(self, "_on_button_focused").bind(confirm_button))
	if cancel_button is Button:
		if not cancel_button.is_connected("pressed", Callable(self, "_on_cancel_pressed")):
			cancel_button.connect("pressed", Callable(self, "_on_cancel_pressed"))
		if not cancel_button.is_connected("focus_entered", Callable(self, "_on_button_focused").bind(cancel_button)):
			cancel_button.connect("focus_entered", Callable(self, "_on_button_focused").bind(cancel_button))

func set_cancel_button_focus():
	if cancel_button is Button:
		cancel_button.grab_focus()
		print("Focus set to ConfirmButton")
	else:
		print("ConfirmButton not found or not a Button")

func _on_confirm_pressed() -> void:
	emit_signal("exit_confirmed")
	get_tree().quit()

func _on_cancel_pressed() -> void:
	emit_signal("exit_cancelled")
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
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_cancel_button_focus()
