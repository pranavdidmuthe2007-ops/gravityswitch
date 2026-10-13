extends Control

@onready var play_btn: Button = $VBoxBottom/PlayBtn
@onready var levels_btn: Button = $VBoxBottom/LevelsBtn
@onready var endless_btn: Button = $VBoxBottom/EndlessBtn
@onready var skins_btn: Button = $VBoxBottom/HBoxExtras/SkinsBtn
@onready var achievements_btn: Button = $VBoxBottom/HBoxExtras/AchievementsBtn
@onready var settings_btn: Button = $TopBar/HBox/SettingsBtn
@onready var demo_character: Node2D = $CenterDemo/Character
@onready var demo_trail: Line2D = $CenterDemo/Trail

var demo_time: float = 0.0
var is_demo_up: bool = false
var next_flip_time: float = 1.0

func _ready() -> void:
	AudioManager.play_music()
	play_btn.pressed.connect(_on_play_pressed)
	levels_btn.pressed.connect(_on_levels_pressed)
	endless_btn.pressed.connect(_on_endless_pressed)
	skins_btn.pressed.connect(_on_skins_pressed)
	achievements_btn.pressed.connect(_on_achievements_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)

func _process(delta: float) -> void:
	demo_time += delta
	if demo_time >= next_flip_time:
		is_demo_up = not is_demo_up
		next_flip_time = demo_time + 1.2
		var target_y := -90.0 if is_demo_up else 90.0
		var tween := create_tween()
		tween.tween_property(demo_character, "position:y", target_y, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(demo_character, "rotation", PI if is_demo_up else 0.0, 0.3)
	
	if demo_trail and demo_character:
		demo_trail.add_point(demo_character.global_position)
		if demo_trail.get_point_count() > 14:
			demo_trail.remove_point(0)

func _on_play_pressed() -> void:
	AudioManager.play_sfx("click")
	var unlocked := int(SaveManager.data.get("unlocked_level", 1))
	GameState.load_level(unlocked)

func _on_levels_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

func _on_endless_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/gameplay/endless_mode.tscn")

func _on_skins_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/ui/skins_menu.tscn")

func _on_achievements_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/ui/achievements_menu.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")
