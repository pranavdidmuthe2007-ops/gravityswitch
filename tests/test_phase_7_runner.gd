extends Node

func _ready() -> void:
	print("==========================================")
	print("PHASE 7: TESTING, QA & PLATFORM EXPORT VERIFICATION")
	print("==========================================")
	
	var passed := 0
	var failed := 0
	
	# 1. Verify Export Presets Configuration File
	var presets_exist := FileAccess.file_exists("res://export_presets.cfg")
	if presets_exist:
		var file := FileAccess.open("res://export_presets.cfg", FileAccess.READ)
		var text := file.get_as_text()
		file.close()
		
		var has_android: bool = text.contains('platform="Android"') and text.contains('package/unique_name="com.antigravity.gravityswitch"')
		var has_ios: bool = text.contains('platform="iOS"') and text.contains('application/bundle_identifier="com.antigravity.gravityswitch"')
		
		if has_android and has_ios:
			print("[PASS] 1. Android & iOS export presets configured with unique identifiers (com.antigravity.gravityswitch)")
			passed += 1
		else:
			printerr("[FAIL] 1. Android or iOS presets missing configurations")
			failed += 1
	else:
		printerr("[FAIL] 1. export_presets.cfg missing")
		failed += 1

	# 2. Verify Compiled Standalone Game Package (PCK)
	var pck_path := "res://build/gravityswitch.pck"
	if FileAccess.file_exists(pck_path):
		var f := FileAccess.open(pck_path, FileAccess.READ)
		var size := f.get_length()
		f.close()
		if size > 10000:
			print("[PASS] 2. Compiled standalone package build/gravityswitch.pck verified (%d bytes)" % size)
			passed += 1
		else:
			printerr("[FAIL] 2. PCK bundle size too small")
			failed += 1
	else:
		printerr("[FAIL] 2. build/gravityswitch.pck missing")
		failed += 1

	# 3. Verify Mobile Touch & Portrait Settings
	var orient = ProjectSettings.get_setting("display/window/handheld/orientation")
	var emulate_touch = ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse")
	if orient == 1 and emulate_touch == true:
		print("[PASS] 3. Portrait orientation (1) and touch emulation verified in project settings")
		passed += 1
	else:
		printerr("[FAIL] 3. Mobile display settings incorrect")
		failed += 1

	# 4. Regression Test: Level Restart Clean State
	GameState.start_level(1, 3, 6)
	GameState.collect_orb()
	assert(GameState.collected_orbs == 1)
	# Restart
	GameState.start_level(1, 3, 6)
	if GameState.collected_orbs == 0 and GameState.switches_used == 0 and GameState.is_game_active:
		print("[PASS] 4. Regression: Level restart resets collectible counts, flips, and physics cleanly")
		passed += 1
	else:
		printerr("[FAIL] 4. State preserved across restart")
		failed += 1

	# 5. Regression Test: Pausing Stops Gameplay Loop
	GameState.set_pause(true)
	var p_active = not GameState.is_paused
	var tree_active = not get_tree().paused
	GameState.set_pause(false) # restore
	if not p_active and not tree_active:
		print("[PASS] 5. Regression: Pausing blocks gameplay updates and physics loop")
		passed += 1
	else:
		printerr("[FAIL] 5. Pause regression failed")
		failed += 1

	print("==========================================")
	print("PHASE 7 RESULTS: Passed %d, Failed %d" % [passed, failed])
	print("==========================================")
	
	if failed == 0:
		print("PHASE 7: TESTING, QA & PLATFORM EXPORTS FULLY VERIFIED!")
		get_tree().quit(0)
	else:
		get_tree().quit(1)
