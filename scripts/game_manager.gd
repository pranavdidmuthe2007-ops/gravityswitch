extends Node2D

func _ready() -> void:
	# Load current level or fallback to Level 1
	var lvl := GameState.current_level
	var path := GameState.get_level_scene_path(lvl)
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		get_tree().change_scene_to_file("res://scenes/levels/world_1/level_1.tscn")
