extends Node3D

@onready var player = $Player
@onready var score_label: Label = $UI/Control/CoinContainer/CoinsLabel
@onready var platform_generator: PlatformGenerator
@onready var plane = $StaticBody3D/Plane
@onready var background_player = $BackgroundPlayer
@onready var win_dialog = preload("res://assets/ui/win_dialog.tscn")
@onready var menu_dialog = preload("res://assets/ui/menu_dialog.tscn")

var layer_count = Global.get_current_layer()
var menu_dialog_instance: CanvasLayer = null  # Экземпляр диалога меню
var win_dialog_instance: CanvasLayer = null   # Экземпляр диалога победы

var coin = 0

var music_tracks: Array[String] = [
	"res://assets/audio/Background/euphoric_drive.ogg",
	"res://assets/audio/Background/pixel_dreams.ogg",
	"res://assets/audio/Background/pixel_love.ogg",
	"res://assets/audio/Background/retro_adventure.ogg",
	"res://assets/audio/Background/trance_subuplifting.ogg"
]

func _ready() -> void:
	var max_layer = Global.load_best_score()
	if max_layer != 0:
		layer_count = max_layer
		
	randomize()
	background_player.finished.connect(play_random_music)
	play_random_music()
	
	platform_generator = PlatformGenerator.new()
	add_child(platform_generator)
	platform_generator.initialize_plane(plane)
	
	await platform_generator.spawn_clustered_path({
		"turns_count": 1,
		"platforms_per_turn": 10,
		"spiral_step": 1.01,
		"cluster_radius": 16.0,
		"vertical_step": 1.01,
		"difficulty": 1.0,
	})
	
	platform_generator.spawn_win_platform(_on_win_platform_activated)

func play_random_music() -> void:
	var random_track_path := music_tracks[randi() % music_tracks.size()]
	var stream := load(random_track_path)
	if stream is AudioStream:
		background_player.stream = stream
		background_player.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		_restart_level()
	if event.is_action_pressed("ui_cancel"):
		if menu_dialog_instance:
			menu_dialog_instance._on_cancel_pressed()
			menu_dialog_instance = null
		else:
			_show_menu_dialog()
		if get_tree():
			get_tree().root.set_input_as_handled()

func _show_menu_dialog() -> void:
	if menu_dialog_instance || win_dialog_instance:
		return
	menu_dialog_instance = menu_dialog.instantiate()
	add_child(menu_dialog_instance)
	menu_dialog_instance.open_dialog()
	menu_dialog_instance.menu_confirmed.connect(_on_menu_confirmed)
	menu_dialog_instance.exit_menu_cancelled.connect(_on_exit_cancelled)

func _on_menu_confirmed():
	if menu_dialog_instance:
		menu_dialog_instance.queue_free()
		menu_dialog_instance = null
	get_tree().change_scene_to_file("res://assets/menu/menu_scene.tscn")

func _on_exit_cancelled():
	if menu_dialog_instance:
		menu_dialog_instance.queue_free()
		menu_dialog_instance = null
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_coin_collected() -> void:
	coin += 1 
	score_label.text = "Coins: %d" % coin
	Global.add_coins(coin)
	print("Монета собрана")

func _on_win_platform_activated() -> void:
	if win_dialog_instance:  # Проверяем, существует ли уже диалог победы
		return
	print("Победа! Игрок достиг платформы победы.")
	layer_count += 3
	Global.set_layer(layer_count)
	Global.check_new_record(layer_count)
	player._dance_play()
	background_player.stop()
	player.show_floating_text("А теперь новый уровень!")
	_show_win_dialog()

func _show_win_dialog() -> void:
	if win_dialog_instance:  # Проверяем, существует ли уже диалог
		return
	win_dialog_instance = win_dialog.instantiate()
	add_child(win_dialog_instance)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	win_dialog_instance.next_level_pressed.connect(_on_next_level_pressed)
	win_dialog_instance.menu_pressed.connect(_on_menu_pressed)
	win_dialog_instance.tree_exiting.connect(func():
		win_dialog_instance = null  # Очищаем ссылку при закрытии диалога
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	)

func _on_next_level_pressed():
	if win_dialog_instance:
		win_dialog_instance.queue_free()
		win_dialog_instance = null
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_restart_level()

func _on_menu_pressed():
	if win_dialog_instance:
		win_dialog_instance.queue_free()
		win_dialog_instance = null
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://assets/menu/menu_scene.tscn")

func _restart_level() -> void:
	if win_dialog_instance:
		win_dialog_instance.queue_free()
		win_dialog_instance = null
	if menu_dialog_instance:
		menu_dialog_instance.queue_free()
		menu_dialog_instance = null
	get_tree().call_deferred("reload_current_scene")

func _on_area_3d_body_entered() -> void:
	_restart_level()

func _on_reset_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.position = $StaticBody3D/Spawn.position + Vector3(0, 1.0, 0)
		body.show_floating_text("Упсс!", 2.0)
