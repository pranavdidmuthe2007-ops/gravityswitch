extends CanvasLayer

@onready var level_label: Label = $TopBar/HBox/LevelLabel
@onready var orb_label: Label = $TopBar/HBox/OrbBox/OrbLabel
@onready var switches_label: Label = $TopBar/HBox/SwitchBox/SwitchLabel
@onready var pause_btn: Button = $TopBar/HBox/PauseBtn
@onready var tutorial_box: PanelContainer = $TutorialBox
@onready var tutorial_text: Label = $TutorialBox/Margin/TutorialLabel
@onready var gravity_hud_arrow: Polygon2D = $BottomBar/GravityIcon/Arrow

func _ready() -> void:
	pause_btn.pressed.connect(_on_pause_pressed)
	GameState.orb_collected.connect(_on_orb_collected)
	GameState.gravity_switched.connect(_on_gravity_switched)
	_update_labels()
	_check_tutorial()

func _update_labels() -> void:
	level_label.text = "LEVEL %d" % GameState.current_level
	orb_label.text = "%d / %d" % [GameState.collected_orbs, GameState.total_orbs]
	switches_label.text = "FLIPS: %d" % GameState.switches_used

func _on_orb_collected(current: int, total: int) -> void:
	orb_label.text = "%d / %d" % [current, total]
	var tween := create_tween()
	tween.tween_property(orb_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(orb_label, "scale", Vector2(1.0, 1.0), 0.1)

func _on_gravity_switched(is_up: bool) -> void:
	switches_label.text = "FLIPS: %d" % GameState.switches_used
	if gravity_hud_arrow:
		var target_rot: float = PI if is_up else 0.0
		var tween := create_tween()
		tween.tween_property(gravity_hud_arrow, "rotation", target_rot, 0.1)
		gravity_hud_arrow.color = Color(1.0, 0.2, 0.6) if is_up else Color(0.0, 0.9, 1.0)

func _on_pause_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.toggle_pause()

func _check_tutorial() -> void:
	var lvl := GameState.current_level
	if lvl == 1:
		show_tutorial("TAP ANYWHERE TO SWITCH GRAVITY")
	elif lvl == 2:
		show_tutorial("SWITCH TO CEILING TO AVOID SPIKES")
	elif lvl == 3:
		show_tutorial("COLLECT GOLDEN ORBS FOR 3 STARS")
	elif lvl == 11:
		show_tutorial("WATCH OUT FOR MOVING HAZARDS")
	elif lvl == 21:
		show_tutorial("TIMED LASERS AND ROTATING TRAPS AHEAD")
	else:
		tutorial_box.visible = false

func show_tutorial(msg: String) -> void:
	tutorial_text.text = msg
	tutorial_box.visible = true
	var tween := create_tween()
	tween.tween_interval(3.5)
	tween.tween_property(tutorial_box, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): tutorial_box.visible = false)
