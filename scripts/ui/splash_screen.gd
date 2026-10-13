extends Control

@onready var character_demo: Node2D = $CenterContainer/CharacterDemo
@onready var title_label: Label = $VBox/TitleLabel
@onready var sub_label: Label = $VBox/SubLabel

var demo_time: float = 0.0

func _ready() -> void:
	AudioManager.play_music()
	_animate_splash()

func _process(delta: float) -> void:
	demo_time += delta
	if character_demo:
		# Flip character vertically smoothly between y = -60 and y = 60
		character_demo.position.y = sin(demo_time * 4.0) * 50.0

func _animate_splash() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	tween.tween_interval(1.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
