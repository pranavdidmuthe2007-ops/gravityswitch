extends CanvasLayer

@onready var resume_btn: Button = $Panel/VBox/ResumeBtn
@onready var restart_btn: Button = $Panel/VBox/RestartBtn
@onready var levels_btn: Button = $Panel/VBox/LevelsBtn
@onready var settings_btn: Button = $Panel/VBox/SettingsBtn
@onready var menu_btn: Button = $Panel/VBox/MenuBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_btn.pressed.connect(_on_resume_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	levels_btn.pressed.connect(_on_levels_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	GameState.game_paused.connect(_on_game_paused)
	visible = GameState.is_paused

func _on_game_paused(paused: bool) -> void:
	visible = paused

func _on_resume_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.set_pause(false)

func _on_restart_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.restart_level()

func _on_levels_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.go_to_level_select()

func _on_settings_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")

func _on_menu_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.go_to_main_menu()
