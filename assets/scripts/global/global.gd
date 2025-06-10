extends Node

# Переменная для хранения пути к текущему скину
var current_skin_path: String = "res://Assets/Characters/Bear/player_bear.tscn"
var current_layer = 10
var current_score: int = 0
var best_score: int = 0
var all_coins: int = 0

const SCORE_SAVE_PATH = "user://save_data.dat"
const COINS_SAVE_PATH = "user://coins_data.dat"

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
	load_best_score()
	load_coins()

func save_best_score() -> void:
	var file = FileAccess.open(SCORE_SAVE_PATH, FileAccess.WRITE)
	if file:
		var save_data = {
			"best_score": best_score
		}
		file.store_var(save_data)
		file.close()
		print("Рекорд сохранён: ", best_score)
	else:
		push_error("Не удалось открыть файл для сохранения рекорда: ", SCORE_SAVE_PATH)

func load_best_score() -> int:
	if FileAccess.file_exists(SCORE_SAVE_PATH):
		var file = FileAccess.open(SCORE_SAVE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			if save_data:
				best_score = save_data.get("best_score", 0)
				print("Рекорд загружен: ", best_score)
			else:
				push_error("Ошибка чтения данных рекорда из файла: ", SCORE_SAVE_PATH)
			file.close()
		else:
			push_error("Не удалось открыть файл для чтения рекорда: ", SCORE_SAVE_PATH)
	return best_score

func save_coins() -> void:
	var file = FileAccess.open(COINS_SAVE_PATH, FileAccess.WRITE)
	if file:
		var save_data = {
			"all_coins": all_coins
		}
		file.store_var(save_data)
		file.close()
		print("Монеты сохранены: ", all_coins)
	else:
		push_error("Не удалось открыть файл для сохранения монет: ", COINS_SAVE_PATH)

func load_coins() -> int:
	if FileAccess.file_exists(COINS_SAVE_PATH):
		var file = FileAccess.open(COINS_SAVE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			if save_data:
				all_coins = save_data.get("all_coins", 0)
				print("Монеты загружены: ", all_coins)
			else:
				push_error("Ошибка чтения данных монет из файла: ", COINS_SAVE_PATH)
			file.close()
		else:
			push_error("Не удалось открыть файл для чтения монет: ", COINS_SAVE_PATH)
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
	all_coins  = 0
	save_best_score()
	save_coins()
	print("Рекорд сброшён до 0")

# Добавление монет
func add_coins(coins: int) -> void:
	if coins < 0:
		push_warning("Попытка добавить отрицательное количество монет: ", coins)
		return
	all_coins += coins
	save_coins()  # Сохраняем только монеты
	print("Добавлено монет: ", coins, ", всего монет: ", all_coins)

# Получение текущего количества монет
func get_all_coins() -> int:
	return all_coins
