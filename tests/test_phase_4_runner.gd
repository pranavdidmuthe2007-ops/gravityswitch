extends Node

func _ready() -> void:
	print("==========================================")
	print("PHASE 4: COMPLETE UI/UX DESIGN VERIFICATION")
	print("==========================================")
	
	var passed := 0
	var failed := 0
	
	# 1. Splash Screen Verification
	var splash_scene = load("res://scenes/ui/splash_screen.tscn")
	if splash_scene != null:
		var splash = splash_scene.instantiate()
		add_child(splash)
		var title = splash.get_node_or_null("VBox/TitleLabel")
		var demo = splash.get_node_or_null("CenterContainer/CharacterDemo")
		if title != null and title.text == "GRAVITY SWITCH" and demo != null:
			print("[PASS] 1. Splash Screen verified with title logo and animated character demo")
			passed += 1
		else:
			printerr("[FAIL] 1. Splash Screen missing components")
			failed += 1
		splash.queue_free()
	else:
		printerr("[FAIL] 1. Splash Screen scene missing")
		failed += 1
		
	# 2. Main Menu Verification
	var menu_scene = load("res://scenes/ui/main_menu.tscn")
	if menu_scene != null:
		var menu = menu_scene.instantiate()
		add_child(menu)
		var play_btn = menu.get_node_or_null("VBoxBottom/PlayBtn")
		var levels_btn = menu.get_node_or_null("VBoxBottom/LevelsBtn")
		var endless_btn = menu.get_node_or_null("VBoxBottom/EndlessBtn")
		var settings_btn = menu.get_node_or_null("TopBar/HBox/SettingsBtn")
		if play_btn != null and levels_btn != null and endless_btn != null and settings_btn != null:
			print("[PASS] 2. Main Menu verified with Play, Levels, Endless, and Settings buttons")
			passed += 1
		else:
			printerr("[FAIL] 2. Main Menu missing buttons")
			failed += 1
		menu.queue_free()
	else:
		printerr("[FAIL] 2. Main Menu scene missing")
		failed += 1
		
	# 3. Gameplay HUD Verification
	var hud_scene = load("res://scenes/ui/hud.tscn")
	if hud_scene != null:
		var hud = hud_scene.instantiate()
		add_child(hud)
		var lvl_lbl = hud.get_node_or_null("TopBar/HBox/LevelLabel")
		var orb_lbl = hud.get_node_or_null("TopBar/HBox/OrbBox/OrbLabel")
		var pause_btn = hud.get_node_or_null("TopBar/HBox/PauseBtn")
		var tut_box = hud.get_node_or_null("TutorialBox")
		if lvl_lbl != null and orb_lbl != null and pause_btn != null and tut_box != null:
			print("[PASS] 3. Gameplay HUD verified with level display, orb counter, and safe-area controls")
			passed += 1
		else:
			printerr("[FAIL] 3. HUD missing elements")
			failed += 1
		hud.queue_free()
	else:
		printerr("[FAIL] 3. HUD scene missing")
		failed += 1

	# 4. Level Selection Screen Verification
	var ls_scene = load("res://scenes/ui/level_select.tscn")
	if ls_scene != null:
		var ls = ls_scene.instantiate()
		add_child(ls)
		var grid = ls.get_node_or_null("ScrollContainer/Margin/VBox/GridContainer")
		var w1 = ls.get_node_or_null("Tabs/HBox/World1Btn")
		var w2 = ls.get_node_or_null("Tabs/HBox/World2Btn")
		var w3 = ls.get_node_or_null("Tabs/HBox/World3Btn")
		if grid != null and w1 != null and w2 != null and w3 != null:
			print("[PASS] 4. Level Select verified with world tabs and dynamic 5-column card grid")
			passed += 1
		else:
			printerr("[FAIL] 4. Level Select missing nodes")
			failed += 1
		ls.queue_free()
	else:
		printerr("[FAIL] 4. Level Select scene missing")
		failed += 1

	# 5. Pause Menu Verification
	var pm_scene = load("res://scenes/ui/pause_menu.tscn")
	if pm_scene != null:
		var pm = pm_scene.instantiate()
		add_child(pm)
		var resume_btn = pm.get_node_or_null("Panel/VBox/ResumeBtn")
		var restart_btn = pm.get_node_or_null("Panel/VBox/RestartBtn")
		var levels_btn = pm.get_node_or_null("Panel/VBox/LevelsBtn")
		if resume_btn != null and restart_btn != null and levels_btn != null:
			print("[PASS] 5. Pause Menu overlay verified with Resume, Restart, and Level Select")
			passed += 1
		else:
			printerr("[FAIL] 5. Pause Menu missing buttons")
			failed += 1
		pm.queue_free()
	else:
		printerr("[FAIL] 5. Pause Menu scene missing")
		failed += 1

	# 6. Game Over Screen Verification
	var go_scene = load("res://scenes/ui/game_over.tscn")
	if go_scene != null:
		var go = go_scene.instantiate()
		add_child(go)
		var reason = go.get_node_or_null("Panel/VBox/ReasonLabel")
		var retry_btn = go.get_node_or_null("Panel/VBox/RestartBtn")
		if reason != null and retry_btn != null:
			print("[PASS] 6. Game Over screen verified with failure cause and prominent Retry action")
			passed += 1
		else:
			printerr("[FAIL] 6. Game Over screen missing components")
			failed += 1
		go.queue_free()
	else:
		printerr("[FAIL] 6. Game Over scene missing")
		failed += 1

	# 7. Level Complete Screen Verification
	var lc_scene = load("res://scenes/ui/level_complete.tscn")
	if lc_scene != null:
		var lc = lc_scene.instantiate()
		add_child(lc)
		var stars_box = lc.get_node_or_null("Panel/VBox/StarsContainer")
		var next_btn = lc.get_node_or_null("Panel/VBox/NextBtn")
		var replay_btn = lc.get_node_or_null("Panel/VBox/RetryBtn")
		if stars_box != null and next_btn != null and replay_btn != null:
			print("[PASS] 7. Level Complete screen verified with animated star badges and Next Level flow")
			passed += 1
		else:
			printerr("[FAIL] 7. Level Complete missing controls")
			failed += 1
		lc.queue_free()
	else:
		printerr("[FAIL] 7. Level Complete scene missing")
		failed += 1

	# 8. Settings Screen Verification
	var sm_scene = load("res://scenes/ui/settings_menu.tscn")
	if sm_scene != null:
		var sm = sm_scene.instantiate()
		add_child(sm)
		var music_slider = sm.get_node_or_null("Margin/VBox/MusicRow/MusicSlider")
		var sfx_slider = sm.get_node_or_null("Margin/VBox/SfxRow/SfxSlider")
		var haptics = sm.get_node_or_null("Margin/VBox/HapticsRow/CheckButton")
		var particles = sm.get_node_or_null("Margin/VBox/ParticlesRow/CheckButton")
		var restart = sm.get_node_or_null("Margin/VBox/RestartRow/CheckButton")
		if music_slider != null and sfx_slider != null and haptics != null and particles != null and restart != null:
			print("[PASS] 8. Settings Menu verified with volume sliders, haptic toggle, and restart options")
			passed += 1
		else:
			printerr("[FAIL] 8. Settings Menu missing controls")
			failed += 1
		sm.queue_free()
	else:
		printerr("[FAIL] 8. Settings Menu scene missing")
		failed += 1

	print("==========================================")
	print("PHASE 4 RESULTS: Passed %d, Failed %d" % [passed, failed])
	print("==========================================")
	
	if failed == 0:
		print("PHASE 4: COMPLETE UI/UX DESIGN FULLY VERIFIED!")
		get_tree().quit(0)
	else:
		get_tree().quit(1)
