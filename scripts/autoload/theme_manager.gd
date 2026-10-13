extends Node

signal theme_changed(theme_info: Dictionary)

const THEMES: Dictionary = {
	"cyber_cyan": {
		"id": "cyber_cyan",
		"name": "Cyber Cyan",
		"primary": Color(0.0, 1.0, 1.0, 1.0),
		"accent": Color(0.0, 0.55, 1.0, 1.0),
		"glow": Color(0.0, 1.0, 1.0, 0.3),
		"stars_required": 0
	},
	"neon_magenta": {
		"id": "neon_magenta",
		"name": "Neon Magenta",
		"primary": Color(1.0, 0.1, 0.55, 1.0),
		"accent": Color(0.7, 0.0, 1.0, 1.0),
		"glow": Color(1.0, 0.1, 0.55, 0.3),
		"stars_required": 15
	},
	"solar_amber": {
		"id": "solar_amber",
		"name": "Solar Amber",
		"primary": Color(1.0, 0.7, 0.0, 1.0),
		"accent": Color(1.0, 0.3, 0.0, 1.0),
		"glow": Color(1.0, 0.7, 0.0, 0.3),
		"stars_required": 30
	},
	"quantum_emerald": {
		"id": "quantum_emerald",
		"name": "Quantum Emerald",
		"primary": Color(0.0, 1.0, 0.5, 1.0),
		"accent": Color(0.0, 0.7, 0.3, 1.0),
		"glow": Color(0.0, 1.0, 0.5, 0.3),
		"stars_required": 45
	},
	"plasma_violet": {
		"id": "plasma_violet",
		"name": "Plasma Violet",
		"primary": Color(0.75, 0.25, 1.0, 1.0),
		"accent": Color(0.45, 0.0, 0.9, 1.0),
		"glow": Color(0.75, 0.25, 1.0, 0.3),
		"stars_required": 60
	}
}

var current_theme_id: String = "cyber_cyan"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var saved_id: String = SaveManager.data.get("selected_theme", "cyber_cyan")
	if THEMES.has(saved_id):
		current_theme_id = saved_id
	else:
		current_theme_id = "cyber_cyan"

func get_current_theme() -> Dictionary:
	return THEMES.get(current_theme_id, THEMES["cyber_cyan"])

func set_theme(theme_id: String) -> bool:
	if not THEMES.has(theme_id):
		return false
	if not is_theme_unlocked(theme_id):
		return false
		
	current_theme_id = theme_id
	SaveManager.data["selected_theme"] = theme_id
	SaveManager.save_game()
	theme_changed.emit(THEMES[theme_id])
	return true

func is_theme_unlocked(theme_id: String) -> bool:
	if not THEMES.has(theme_id):
		return false
	var required_stars: int = THEMES[theme_id]["stars_required"]
	var total_stars: int = 0
	for l in range(1, 31):
		total_stars += SaveManager.get_level_stars(l)
	return total_stars >= required_stars

func get_all_themes() -> Array:
	return THEMES.values()
