extends Control

@onready var grid_container: GridContainer = $ScrollContainer/Margin/VBox/GridContainer
@onready var back_btn: Button = $TopBar/HBox/BackBtn
@onready var stats_label: Label = $TopBar/HBox/StatsLabel
@onready var world1_btn: Button = $Tabs/HBox/World1Btn
@onready var world2_btn: Button = $Tabs/HBox/World2Btn
@onready var world3_btn: Button = $Tabs/HBox/World3Btn

var selected_world: int = 1

func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	world1_btn.pressed.connect(func(): _select_world(1))
	world2_btn.pressed.connect(func(): _select_world(2))
	world3_btn.pressed.connect(func(): _select_world(3))
	_update_stats()
	_select_world(1)

func _update_stats() -> void:
	var unlocked := int(SaveManager.data.get("unlocked_level", 1))
	var total_stars := 0
	for l in range(1, 31):
		total_stars += SaveManager.get_level_stars(l)
	stats_label.text = "Unlocked: %d/30   ★ %d/90" % [unlocked, total_stars]

func _select_world(world: int) -> void:
	selected_world = world
	world1_btn.modulate = Color(1, 1, 1) if world == 1 else Color(0.6, 0.6, 0.7)
	world2_btn.modulate = Color(1, 1, 1) if world == 2 else Color(0.6, 0.6, 0.7)
	world3_btn.modulate = Color(1, 1, 1) if world == 3 else Color(0.6, 0.6, 0.7)
	_build_grid()

func _build_grid() -> void:
	for child in grid_container.get_children():
		child.queue_free()
		
	var start_level := (selected_world - 1) * 10 + 1
	var end_level := start_level + 9
	var unlocked_level := int(SaveManager.data.get("unlocked_level", 1))
	
	for lvl in range(start_level, end_level + 1):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(110, 120)
		btn.focus_mode = Control.FOCUS_NONE
		
		var is_unlocked := lvl <= unlocked_level
		var stars := SaveManager.get_level_stars(lvl)
		
		var star_text := ""
		for s in range(3):
			star_text += "★" if s < stars else "☆"
			
		if is_unlocked:
			btn.text = "%d\n\n%s" % [lvl, star_text]
			btn.pressed.connect(func():
				AudioManager.play_sfx("click")
				GameState.load_level(lvl)
			)
		else:
			btn.text = "🔒\n\n%d" % lvl
			btn.disabled = true
			btn.modulate = Color(0.5, 0.5, 0.6, 0.7)
			
		grid_container.add_child(btn)

func _on_back_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
