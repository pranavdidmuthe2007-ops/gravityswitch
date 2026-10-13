extends Node

signal achievement_unlocked(id: String, info: Dictionary)

const ACHIEVEMENTS: Dictionary = {
	"first_flip": {
		"id": "first_flip",
		"title": "First Flip",
		"description": "Reversed gravity for the first time.",
		"icon": "⇕"
	},
	"orbs_10": {
		"id": "orbs_10",
		"title": "Spark Collector",
		"description": "Collected 10 total energy orbs.",
		"icon": "◆"
	},
	"orbs_50": {
		"id": "orbs_50",
		"title": "Orb Hoarder",
		"description": "Collected 50 total energy orbs.",
		"icon": "💎"
	},
	"world_1_clear": {
		"id": "world_1_clear",
		"title": "Cadet Graduate",
		"description": "Completed World 1 (Neon Training).",
		"icon": "🏆"
	},
	"world_2_clear": {
		"id": "world_2_clear",
		"title": "Factory Mechanic",
		"description": "Completed World 2 (Gravity Factory).",
		"icon": "⚙"
	},
	"world_3_clear": {
		"id": "world_3_clear",
		"title": "Quantum Master",
		"description": "Conquered all 30 levels and World 3.",
		"icon": "👑"
	},
	"stars_30": {
		"id": "stars_30",
		"title": "Star Gatherer",
		"description": "Earned 30 stars.",
		"icon": "★"
	},
	"stars_60": {
		"id": "stars_60",
		"title": "Starlight Adept",
		"description": "Earned 60 stars.",
		"icon": "🌟"
	},
	"stars_90": {
		"id": "stars_90",
		"title": "Galaxy Legend",
		"description": "Achieved perfection: all 90 stars!",
		"icon": "✨"
	},
	"endless_250": {
		"id": "endless_250",
		"title": "Endless Runner",
		"description": "Traveled 250m in Endless Mode.",
		"icon": "🚀"
	},
	"endless_500": {
		"id": "endless_500",
		"title": "Endless Legend",
		"description": "Traveled 500m in Endless Mode.",
		"icon": "⚡"
	},
	"flips_100": {
		"id": "flips_100",
		"title": "Gravity Master",
		"description": "Performed 100 total gravity switches.",
		"icon": "🌀"
	}
}

var toast_layer: CanvasLayer
var toast_panel: PanelContainer
var toast_label_title: Label
var toast_label_desc: Label
var toast_label_icon: Label
var is_showing_toast: bool = false
var toast_queue: Array[String] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_toast_ui()
	_connect_game_events()

func _connect_game_events() -> void:
	if not GameState.gravity_switched.is_connected(_on_gravity_switched):
		GameState.gravity_switched.connect(_on_gravity_switched)
	if not GameState.orb_collected.is_connected(_on_orb_collected):
		GameState.orb_collected.connect(_on_orb_collected)
	if not GameState.level_completed.is_connected(_on_level_completed):
		GameState.level_completed.connect(_on_level_completed)

func is_unlocked(id: String) -> bool:
	if not SaveManager.data.has("achievements"):
		SaveManager.data["achievements"] = {}
	return SaveManager.data["achievements"].has(id)

func unlock(id: String) -> void:
	if not ACHIEVEMENTS.has(id):
		return
	if is_unlocked(id):
		return
		
	if not SaveManager.data.has("achievements"):
		SaveManager.data["achievements"] = {}
		
	SaveManager.data["achievements"][id] = true
	SaveManager.save_game()
	
	achievement_unlocked.emit(id, ACHIEVEMENTS[id])
	_enqueue_toast(id)

func check_stats() -> void:
	# Check orbs
	var total_orbs: int = int(SaveManager.data.get("total_orbs", 0))
	if total_orbs >= 10: unlock("orbs_10")
	if total_orbs >= 50: unlock("orbs_50")
	
	# Check stars
	var total_stars: int = 0
	for l in range(1, 31):
		total_stars += SaveManager.get_level_stars(l)
	if total_stars >= 30: unlock("stars_30")
	if total_stars >= 60: unlock("stars_60")
	if total_stars >= 90: unlock("stars_90")
	
	# Check world clears
	if SaveManager.get_level_stars(10) > 0: unlock("world_1_clear")
	if SaveManager.get_level_stars(20) > 0: unlock("world_2_clear")
	if SaveManager.get_level_stars(30) > 0: unlock("world_3_clear")

func _on_gravity_switched(_is_up: bool) -> void:
	unlock("first_flip")
	var flips: int = int(SaveManager.data.get("total_flips", 0)) + 1
	SaveManager.data["total_flips"] = flips
	if flips >= 100:
		unlock("flips_100")

func _on_orb_collected(_current: int, _total: int) -> void:
	check_stats()

func _on_level_completed(_stars: int, _orbs: int, _switches: int, _time_taken: float) -> void:
	check_stats()

# --- Toast UI ---

func _setup_toast_ui() -> void:
	toast_layer = CanvasLayer.new()
	toast_layer.layer = 100
	add_child(toast_layer)
	
	toast_panel = PanelContainer.new()
	toast_panel.custom_minimum_size = Vector2(500, 90)
	toast_panel.anchor_left = 0.5
	toast_panel.anchor_right = 0.5
	toast_panel.offset_left = -250
	toast_panel.offset_right = 250
	toast_panel.offset_top = -120
	toast_panel.offset_bottom = -20
	toast_panel.visible = false
	toast_layer.add_child(toast_panel)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	toast_panel.add_child(margin)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)
	
	toast_label_icon = Label.new()
	toast_label_icon.add_theme_font_size_override("font_size", 38)
	toast_label_icon.text = "🏆"
	hbox.add_child(toast_label_icon)
	
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	toast_label_title = Label.new()
	toast_label_title.add_theme_color_override("font_color", Color(0, 1, 1))
	toast_label_title.add_theme_font_size_override("font_size", 20)
	toast_label_title.text = "ACHIEVEMENT UNLOCKED!"
	vbox.add_child(toast_label_title)
	
	toast_label_desc = Label.new()
	toast_label_desc.add_theme_color_override("font_color", Color(0.9, 0.95, 1))
	toast_label_desc.add_theme_font_size_override("font_size", 16)
	toast_label_desc.text = "Description here"
	vbox.add_child(toast_label_desc)

func _enqueue_toast(id: String) -> void:
	toast_queue.append(id)
	if not is_showing_toast:
		_show_next_toast()

func _show_next_toast() -> void:
	if toast_queue.is_empty():
		is_showing_toast = false
		return
		
	is_showing_toast = true
	var id: String = toast_queue.pop_front()
	var info: Dictionary = ACHIEVEMENTS[id]
	
	toast_label_icon.text = info["icon"]
	toast_label_title.text = "UNLOCKED: " + info["title"]
	toast_label_desc.text = info["description"]
	
	toast_panel.visible = true
	toast_panel.position.y = -120
	AudioManager.play_sfx("win", 1.2)
	
	var tween := create_tween()
	# Slide down to y = 40
	tween.tween_property(toast_panel, "position:y", 40.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.6)
	# Slide back up
	tween.tween_property(toast_panel, "position:y", -120.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		toast_panel.visible = false
		_show_next_toast()
	)
