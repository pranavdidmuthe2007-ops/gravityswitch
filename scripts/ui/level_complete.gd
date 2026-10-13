extends CanvasLayer

@onready var title_label: Label = $Panel/VBox/Title
@onready var star1: Label = $Panel/VBox/StarsContainer/Star1
@onready var star2: Label = $Panel/VBox/StarsContainer/Star2
@onready var star3: Label = $Panel/VBox/StarsContainer/Star3
@onready var stats_label: Label = $Panel/VBox/StatsLabel
@onready var next_btn: Button = $Panel/VBox/NextBtn
@onready var retry_btn: Button = $Panel/VBox/RetryBtn
@onready var levels_btn: Button = $Panel/VBox/LevelsBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	next_btn.pressed.connect(_on_next_pressed)
	retry_btn.pressed.connect(_on_retry_pressed)
	levels_btn.pressed.connect(_on_levels_pressed)
	visible = false

func show_complete(stars: int, orbs: int, switches: int, _time: float) -> void:
	visible = true
	if GameState.current_level >= 30:
		title_label.text = "GAME COMPLETE!"
		next_btn.text = "CREDITS / LEVELS"
	else:
		title_label.text = "LEVEL COMPLETED!"
		next_btn.text = "NEXT LEVEL ▶"
		
	stats_label.text = "Orbs: %d / %d   |   Flips: %d" % [orbs, GameState.total_orbs, switches]
	
	# Reset stars
	star1.modulate = Color(0.3, 0.3, 0.4)
	star2.modulate = Color(0.3, 0.3, 0.4)
	star3.modulate = Color(0.3, 0.3, 0.4)
	star1.scale = Vector2(0.5, 0.5)
	star2.scale = Vector2(0.5, 0.5)
	star3.scale = Vector2(0.5, 0.5)
	
	# Animate stars popping in
	var stars_arr := [star1, star2, star3]
	var tween := create_tween()
	for i in range(stars):
		var star_node: Label = stars_arr[i]
		tween.tween_interval(0.18)
		tween.tween_callback(func():
			star_node.modulate = Color(1.0, 0.85, 0.1)
			AudioManager.play_sfx("orb", 1.0 + i * 0.2)
		)
		tween.tween_property(star_node, "scale", Vector2(1.2, 1.2), 0.12)
		tween.tween_property(star_node, "scale", Vector2(1.0, 1.0), 0.08)

func _on_next_pressed() -> void:
	AudioManager.play_sfx("click")
	if GameState.current_level >= 30:
		GameState.go_to_level_select()
	else:
		GameState.load_next_level()

func _on_retry_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.restart_level()

func _on_levels_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.go_to_level_select()
