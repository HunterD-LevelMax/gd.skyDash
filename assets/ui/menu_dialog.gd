extends CanvasLayer

signal menu_confirmed
signal exit_menu_cancelled

@onready var menu_button = $Panel/VBoxContainer/ButtonMenu
@onready var cancel_button = $Panel/VBoxContainer/ButtonCancel

func _ready():
	_show_title()
	$Panel.modulate.a = 0
	var tween = create_tween()
	tween.tween_property($Panel, "modulate:a", 1.0, 0.3)
	# Устанавливаем режим мыши для UI
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Устанавливаем фокус на кнопку "MenuButton"
	set_cancel_button_focus()

	if menu_button is Button:
		if not menu_button.is_connected("pressed", Callable(self, "_on_menu_pressed")):
			menu_button.connect("pressed", Callable(self, "_on_menu_pressed"))
		if not menu_button.is_connected("focus_entered", Callable(self, "_on_button_focused").bind(menu_button)):
			menu_button.connect("focus_entered", Callable(self, "_on_button_focused").bind(menu_button))
	if cancel_button and cancel_button is Button:
		if not cancel_button.is_connected("pressed", Callable(self, "_on_cancel_pressed")):
			cancel_button.connect("pressed", Callable(self, "_on_cancel_pressed"))
		if not cancel_button.is_connected("focus_entered", Callable(self, "_on_button_focused").bind(cancel_button)):
			cancel_button.connect("focus_entered", Callable(self, "_on_button_focused").bind(cancel_button))

func set_cancel_button_focus():
	if cancel_button is Button:
		cancel_button.grab_focus()
		print("Focus set to MenuButton")
	else:
		print("MenuButton not found or not a Button")

func _on_menu_pressed() -> void:
	emit_signal("menu_confirmed")

func _on_cancel_pressed() -> void:
	emit_signal("exit_menu_cancelled")
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
	_show_title()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_cancel_button_focus()

func _show_title() -> void:
	var score = Global.get_current_layer()
	$Panel/Title.text = "🌟 МОЙ СЧЁТ! " + str(score) + " 🌟"
