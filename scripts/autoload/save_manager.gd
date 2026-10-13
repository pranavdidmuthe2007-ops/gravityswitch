extends Node

const SAVE_PATH: String = "user://gravity_switch_save.json"

var data: Dictionary = {
	"unlocked_level": 1,
	"level_stars": {},
	"level_collectibles": {},
	"best_switches": {},
	"total_orbs": 0,
	"settings": {
		"music_volume": 0.8,
		"sfx_volume": 0.9,
		"haptics": true,
		"particles": true,
		"auto_restart": false
	}
}

func _ready() -> void:
	load_game()

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string := JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	
	var content := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result := json.parse(content)
	if parse_result == OK and typeof(json.data) == TYPE_DICTIONARY:
		var loaded: Dictionary = json.data
		if loaded.has("unlocked_level") and typeof(loaded["unlocked_level"]) in [TYPE_INT, TYPE_FLOAT]:
			data["unlocked_level"] = int(loaded["unlocked_level"])
		if loaded.has("level_stars") and typeof(loaded["level_stars"]) == TYPE_DICTIONARY:
			data["level_stars"] = loaded["level_stars"]
		if loaded.has("level_collectibles") and typeof(loaded["level_collectibles"]) == TYPE_DICTIONARY:
			data["level_collectibles"] = loaded["level_collectibles"]
		if loaded.has("best_switches") and typeof(loaded["best_switches"]) == TYPE_DICTIONARY:
			data["best_switches"] = loaded["best_switches"]
		if loaded.has("total_orbs") and typeof(loaded["total_orbs"]) in [TYPE_INT, TYPE_FLOAT]:
			data["total_orbs"] = int(loaded["total_orbs"])
		if loaded.has("settings") and typeof(loaded["settings"]) == TYPE_DICTIONARY:
			var s: Dictionary = loaded["settings"]
			for k in data["settings"].keys():
				if s.has(k):
					data["settings"][k] = s[k]

func get_level_stars(level: int) -> int:
	var key := str(level)
	if data["level_stars"].has(key):
		return int(data["level_stars"][key])
	return 0

func record_level_completion(level: int, stars: int, orbs: int, switches: int) -> void:
	var key := str(level)
	var prev_stars: int = get_level_stars(level)
	if stars > prev_stars:
		data["level_stars"][key] = stars
	
	var prev_orbs: int = int(data["level_collectibles"].get(key, 0))
	if orbs > prev_orbs:
		data["level_collectibles"][key] = orbs
	
	var prev_switches: int = int(data["best_switches"].get(key, 9999))
	if switches < prev_switches:
		data["best_switches"][key] = switches
		
	if level >= data["unlocked_level"] and level < 30:
		data["unlocked_level"] = level + 1
		
	# Recalculate total orbs
	var tot := 0
	for l_orbs in data["level_collectibles"].values():
		tot += int(l_orbs)
	data["total_orbs"] = tot
	
	save_game()

func is_level_unlocked(level: int) -> bool:
	return level <= data["unlocked_level"]

func set_setting(key: String, value: Variant) -> void:
	if data["settings"].has(key):
		data["settings"][key] = value
		save_game()

func get_setting(key: String, default_val: Variant = null) -> Variant:
	if data["settings"].has(key):
		return data["settings"][key]
	return default_val
