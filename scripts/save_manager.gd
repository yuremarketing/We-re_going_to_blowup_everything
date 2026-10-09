extends Node

const SAVE_PATH = "user://save_data.cfg"

var best_time: float = -1.0
var max_kills: int = 0

func _ready() -> void:
	load_data()

func load_data() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		best_time = config.get_value("stats", "best_time", -1.0)
		max_kills = config.get_value("stats", "max_kills", 0)

func save_stats(current_time: float, current_kills: int, is_victory: bool) -> void:
	var updated = false
	
	if current_kills > max_kills:
		max_kills = current_kills
		updated = true
		
	if is_victory:
		if best_time < 0 or current_time < best_time:
			best_time = current_time
			updated = true
			
	if updated:
		var config = ConfigFile.new()
		# Mantém o que já estava lá (se houver outras seções no futuro)
		if config.load(SAVE_PATH) != OK:
			pass # Arquivo não existia ou falhou, criaremos um novo
			
		config.set_value("stats", "best_time", best_time)
		config.set_value("stats", "max_kills", max_kills)
		config.save(SAVE_PATH)
