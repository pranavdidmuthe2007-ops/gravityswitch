extends Control

@onready var back_btn: Button = $TopBar/HBox/BackBtn
@onready var stars_label: Label = $TopBar/HBox/StarsLabel
@onready var container: VBoxContainer = $ScrollContainer/Margin/VBox

func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	_update_stars()
	_populate_skins()

func _update_stars() -> void:
	var total_stars := 0
	for l in range(1, 31):
		total_stars += SaveManager.get_level_stars(l)
	stars_label.text = "★ %d / 90" % total_stars

func _populate_skins() -> void:
	for child in container.get_children():
		child.queue_free()
		
	var themes: Array = ThemeManager.get_all_themes()
	var current_id: String = ThemeManager.current_theme_id
	var total_stars := 0
	for l in range(1, 31):
		total_stars += SaveManager.get_level_stars(l)
		
	for t in themes:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 100)
		
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_theme_constant_override("margin_top", 16)
		margin.add_theme_constant_override("margin_right", 20)
		margin.add_theme_constant_override("margin_bottom", 16)
		card.add_child(margin)
		
		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 20)
		margin.add_child(hbox)
		
		# Color Swatch Preview
		var swatch := ColorRect.new()
		swatch.custom_minimum_size = Vector2(50, 50)
		swatch.color = t["primary"]
		hbox.add_child(swatch)
		
		var info_box := VBoxContainer.new()
		info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_box)
		
		var name_lbl := Label.new()
		name_lbl.add_theme_font_size_override("font_size", 24)
		name_lbl.add_theme_color_override("font_color", t["primary"])
		name_lbl.text = t["name"]
		info_box.add_child(name_lbl)
		
		var desc_lbl := Label.new()
		desc_lbl.add_theme_font_size_override("font_size", 16)
		desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.8))
		if t["stars_required"] == 0:
			desc_lbl.text = "Default Theme"
		else:
			desc_lbl.text = "Requires %d Stars (You have %d)" % [t["stars_required"], total_stars]
		info_box.add_child(desc_lbl)
		
		# Action Button
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(130, 50)
		btn.focus_mode = Control.FOCUS_NONE
		
		var is_unlocked: bool = total_stars >= t["stars_required"]
		var is_equipped: bool = t["id"] == current_id
		
		if is_equipped:
			btn.text = "EQUIPPED"
			btn.disabled = true
			btn.modulate = Color(0.4, 1.0, 0.4)
		elif is_unlocked:
			btn.text = "EQUIP"
			var theme_id: String = t["id"]
			btn.pressed.connect(func():
				AudioManager.play_sfx("click")
				ThemeManager.set_theme(theme_id)
				_populate_skins()
			)
		else:
			btn.text = "🔒 %d ★" % t["stars_required"]
			btn.disabled = true
			btn.modulate = Color(0.6, 0.6, 0.7, 0.6)
			
		hbox.add_child(btn)
		container.add_child(card)

func _on_back_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
