extends Control

@onready var back_btn: Button = $TopBar/HBox/BackBtn
@onready var music_slider: HSlider = $Margin/VBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $Margin/VBox/SfxRow/SfxSlider
@onready var haptics_check: CheckButton = $Margin/VBox/HapticsRow/CheckButton
@onready var particles_check: CheckButton = $Margin/VBox/ParticlesRow/CheckButton
@onready var restart_check: CheckButton = $Margin/VBox/RestartRow/CheckButton
@onready var reset_btn: Button = $Margin/VBox/ResetBtn

func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	music_slider.value = float(SaveManager.get_setting("music_volume", 0.8)) * 100.0
	sfx_slider.value = float(SaveManager.get_setting("sfx_volume", 0.9)) * 100.0
	haptics_check.button_pressed = bool(SaveManager.get_setting("haptics", true))
	particles_check.button_pressed = bool(SaveManager.get_setting("particles", true))
	restart_check.button_pressed = bool(SaveManager.get_setting("auto_restart", false))
	
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	haptics_check.toggled.connect(_on_haptics_toggled)
	particles_check.toggled.connect(_on_particles_toggled)
	restart_check.toggled.connect(_on_restart_toggled)
	reset_btn.pressed.connect(_on_reset_pressed)

func _on_music_changed(val: float) -> void:
	var normalized := val / 100.0
	SaveManager.set_setting("music_volume", normalized)
	AudioManager.set_music_volume(normalized)

func _on_sfx_changed(val: float) -> void:
	var normalized := val / 100.0
	SaveManager.set_setting("sfx_volume", normalized)
	AudioManager.set_sfx_volume(normalized)

func _on_haptics_toggled(pressed: bool) -> void:
	AudioManager.play_sfx("click")
	SaveManager.set_setting("haptics", pressed)
	if pressed:
		AudioManager.trigger_haptic(40)

func _on_particles_toggled(pressed: bool) -> void:
	AudioManager.play_sfx("click")
	SaveManager.set_setting("particles", pressed)

func _on_restart_toggled(pressed: bool) -> void:
	AudioManager.play_sfx("click")
	SaveManager.set_setting("auto_restart", pressed)

func _on_reset_pressed() -> void:
	AudioManager.play_sfx("click")
	SaveManager.data["unlocked_level"] = 1
	SaveManager.data["level_stars"] = {}
	SaveManager.data["level_collectibles"] = {}
	SaveManager.data["best_switches"] = {}
	SaveManager.data["total_orbs"] = 0
	SaveManager.save_game()
	reset_btn.text = "PROGRESS RESET ✓"
	reset_btn.disabled = true

func _on_back_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
