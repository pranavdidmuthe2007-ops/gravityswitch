extends Control

@onready var back_btn: Button = $TopBar/HBox/BackBtn
@onready var count_label: Label = $TopBar/HBox/CountLabel
@onready var container: VBoxContainer = $ScrollContainer/Margin/VBox

func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	AchievementManager.check_stats()
	_populate_achievements()

func _populate_achievements() -> void:
	for child in container.get_children():
		child.queue_free()
		
	var all_achs: Dictionary = AchievementManager.ACHIEVEMENTS
	var unlocked_count: int = 0
	
	for id in all_achs.keys():
		var info: Dictionary = all_achs[id]
		var is_done: bool = AchievementManager.is_unlocked(id)
		if is_done:
			unlocked_count += 1
			
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 90)
		
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_theme_constant_override("margin_top", 14)
		margin.add_theme_constant_override("margin_right", 20)
		margin.add_theme_constant_override("margin_bottom", 14)
		card.add_child(margin)
		
		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 18)
		margin.add_child(hbox)
		
		var icon_lbl := Label.new()
		icon_lbl.add_theme_font_size_override("font_size", 34)
		icon_lbl.text = info["icon"]
		hbox.add_child(icon_lbl)
		
		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)
		
		var title_lbl := Label.new()
		title_lbl.add_theme_font_size_override("font_size", 22)
		title_lbl.add_theme_color_override("font_color", Color(0, 1, 1) if is_done else Color(0.6, 0.7, 0.8))
		title_lbl.text = info["title"]
		vbox.add_child(title_lbl)
		
		var desc_lbl := Label.new()
		desc_lbl.add_theme_font_size_override("font_size", 16)
		desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9, 0.8) if is_done else Color(0.5, 0.55, 0.65))
		desc_lbl.text = info["description"]
		vbox.add_child(desc_lbl)
		
		var status_lbl := Label.new()
		status_lbl.add_theme_font_size_override("font_size", 18)
		if is_done:
			status_lbl.text = "✓ DONE"
			status_lbl.add_theme_color_override("font_color", Color(0.2, 1, 0.5))
		else:
			status_lbl.text = "🔒 LOCKED"
			status_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
		hbox.add_child(status_lbl)
		
		container.add_child(card)
		
	count_label.text = "Unlocked: %d / %d" % [unlocked_count, all_achs.size()]

func _on_back_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
