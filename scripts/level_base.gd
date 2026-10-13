extends Node2D
class_name LevelBase

@export var level_number: int = 1
@export var orb_target: int = 3
@export var switch_budget_for_star: int = 8
@export var level_length: float = 3400.0

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var exit_portal: Node2D = $ExitPortal
@onready var game_over_ui = $GameOver
@onready var level_complete_ui = $LevelComplete

func _ready() -> void:
	AudioManager.play_music()
	GameState.start_level(level_number, orb_target, switch_budget_for_star)
	GameState.player_died.connect(_on_player_died)
	GameState.level_completed.connect(_on_level_completed)
	
	if exit_portal:
		exit_portal.position = Vector2(level_length, 650)
		
	# Adjust camera position initially
	if player and camera:
		camera.position = Vector2(player.position.x + 180.0, 640.0)

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player) and player.get("is_alive") == true and camera:
		var target_x: float = player.position.x + 180.0
		camera.position.x = lerp(camera.position.x, target_x, delta * 14.0)

func _on_player_died(reason: String) -> void:
	if SaveManager.get_setting("auto_restart", false):
		var timer := get_tree().create_timer(0.4)
		timer.timeout.connect(GameState.restart_level)
	else:
		if game_over_ui:
			game_over_ui.show_game_over(reason)

func _on_level_completed(stars: int, orbs: int, switches: int, time_taken: float) -> void:
	if level_complete_ui:
		level_complete_ui.show_complete(stars, orbs, switches, time_taken)
