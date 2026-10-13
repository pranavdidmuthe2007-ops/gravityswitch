extends CanvasLayer

@onready var reason_label: Label = $Panel/VBox/ReasonLabel
@onready var restart_btn: Button = $Panel/VBox/RestartBtn
@onready var levels_btn: Button = $Panel/VBox/LevelsBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	restart_btn.pressed.connect(_on_restart_pressed)
	levels_btn.pressed.connect(_on_levels_pressed)
	visible = false

func show_game_over(reason: String) -> void:
	reason_label.text = reason
	visible = true
	# Pop in animation
	$Panel.scale = Vector2(0.8, 0.8)
	var tween := create_tween()
	tween.tween_property($Panel, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_restart_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.restart_level()

func _on_levels_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.go_to_level_select()
