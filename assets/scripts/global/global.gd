extends Node

# Переменная для хранения пути к текущему скину
var current_skin_path: String = "res://Assets/Characters/Bear/player_bear.tscn"
var current_layer = 10
var current_score: int = 0
var best_score: int = 0
var all_coins: int = 0

var music_tracks: Array[String] = [
	"res://assets/audio/Background/euphoric_drive.ogg",
	"res://assets/audio/Background/pixel_dreams.ogg",
	"res://assets/audio/Background/pixel_love.ogg",
	"res://assets/audio/Background/retro_adventure.ogg",
	"res://assets/audio/Background/trance_subuplifting.ogg"
]

const SAVE_PATH = "user://user_data.dat"

# Функция для установки пути к скину
func set_skin_path(new_path: String) -> void:
	current_skin_path = new_path

# Функция для получения пути к скину
func get_skin_path() -> String:
	return current_skin_path

func get_current_layer() -> int:
	return current_layer
	
func set_layer(new_layer: int) -> void:
	current_layer = new_layer

func _ready():
	load_data()

func save_data() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var save_data = {
			"best_score": best_score,
			"all_coins": all_coins
		}
		file.store_var(save_data)
		file.close()
		print("Данные сохранены: рекорд = ", best_score, ", монеты = ", all_coins)
	else:
		push_error("Не удалось открыть файл для сохранения: ", SAVE_PATH)

func load_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			if save_data:
				best_score = save_data.get("best_score", 0)
				all_coins = save_data.get("all_coins", 0)
				print("Данные загружены: рекорд = ", best_score, ", монеты = ", all_coins)
			else:
				push_error("Ошибка чтения данных из файла: ", SAVE_PATH)
			file.close()
		else:
			push_error("Не удалось открыть файл для чтения: ", SAVE_PATH)

func save_best_score() -> void:
	save_data()
	print("Рекорд обновлён: ", best_score)

func load_best_score() -> int:
	load_data()
	return best_score

func save_coins() -> void:
	save_data()
	print("Монеты обновлены: ", all_coins)

func load_coins() -> int:
	load_data()
	return all_coins

func check_new_record(score: int) -> bool:
	current_score = score
	print("Проверка рекорда: текущий счёт = ", score, ", лучший счёт = ", best_score)
	if score > best_score:
		best_score = score
		save_best_score()
		print("Новый рекорд установлен: ", best_score)
		return true
	return false

# Сброс рекорда
func reset_best_score() -> void:
	best_score = 0
	save_best_score()
	print("Рекорд сброшён до 0")

# Добавление монет
func add_coins(coins: int) -> void:
	if coins < 0:
		push_warning("Попытка добавить отрицательное количество монет: ", coins)
		return
	all_coins += coins
	save_coins()
	print("Добавлено монет: ", coins, ", всего монет: ", all_coins)

# Получение текущего количества монет
func get_all_coins() -> int:
	return all_coins
