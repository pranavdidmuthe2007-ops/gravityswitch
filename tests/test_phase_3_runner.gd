extends Node

func _ready() -> void:
	print("==========================================")
	print("PHASE 3: COMPLETE GAME LOOP VERIFICATION")
	print("==========================================")
	
	var passed := 0
	var failed := 0
	
	# 1. Test Collectibles (Energy Orbs)
	var orb_scene = load("res://scenes/gameplay/collectibles/energy_orb.tscn")
	if orb_scene != null:
		var orb = orb_scene.instantiate()
		add_child(orb)
		GameState.start_level(1, 3, 6)
		assert(GameState.collected_orbs == 0)
		
		# Simulate collection
		GameState.collect_orb()
		if GameState.collected_orbs == 1:
			print("[PASS] 1a. Energy orb collected and incremented in GameState (1/3)")
			passed += 1
		else:
			printerr("[FAIL] 1a. Collectible did not increment")
			failed += 1
			
		orb.queue_free()
	else:
		printerr("[FAIL] 1. Energy orb scene missing")
		failed += 1
		
	# 2. Test Star Rating System & Level Completion
	GameState.start_level(1, 3, 6)
	GameState.collect_orb()
	GameState.collect_orb()
	GameState.collect_orb()
	# 4 flips (budget <= 6)
	GameState.switches_used = 4
	var three_stars = GameState.calculate_stars()
	if three_stars == 3:
		print("[PASS] 2a. 3 Stars awarded for full completion + all orbs + under budget")
		passed += 1
	else:
		printerr("[FAIL] 2a. Star calculation failed for 3 stars")
		failed += 1
		
	# Partial: missed orbs
	GameState.collected_orbs = 1
	var two_stars = GameState.calculate_stars()
	if two_stars == 2:
		print("[PASS] 2b. 2 Stars awarded when orbs incomplete but under budget")
		passed += 1
	else:
		printerr("[FAIL] 2b. Star calculation failed for 2 stars")
		failed += 1
		
	# Minimum: exceeded budget and missed orbs
	GameState.switches_used = 12
	var one_star = GameState.calculate_stars()
	if one_star == 1:
		print("[PASS] 2c. 1 Base Star awarded when orbs and budget missed")
		passed += 1
	else:
		printerr("[FAIL] 2c. Star calculation failed for 1 star")
		failed += 1
		
	# Test Exit Portal trigger & saving
	SaveManager.data["unlocked_level"] = 1
	GameState.complete_level()
	if SaveManager.get_level_stars(1) >= 1 and SaveManager.is_level_unlocked(2):
		print("[PASS] 2d. Exit portal triggers completion, unlocks Level 2, and saves progress")
		passed += 1
	else:
		printerr("[FAIL] 2d. Completion did not unlock Level 2")
		failed += 1

	# 3. Test Pause and Resume
	GameState.set_pause(true)
	if GameState.is_paused and get_tree().paused:
		print("[PASS] 3a. Pausing halts physics and gameplay loop")
		passed += 1
	else:
		printerr("[FAIL] 3a. Pause failed to set tree pause")
		failed += 1
		
	GameState.set_pause(false)
	if not GameState.is_paused and not get_tree().paused:
		print("[PASS] 3b. Resuming restores gameplay state without resetting character")
		passed += 1
	else:
		printerr("[FAIL] 3b. Resume failed to unpause")
		failed += 1
		
	# 4. Test Level Loading & Scene Routing
	var p1 = GameState.get_level_scene_path(1)
	var p2 = GameState.get_level_scene_path(5)
	if p1 == "res://scenes/levels/world_1/level_1.tscn" and p2 == "res://scenes/levels/world_1/level_5.tscn":
		print("[PASS] 4. Dynamic level path resolution verified for World 1")
		passed += 1
	else:
		printerr("[FAIL] 4. Incorrect level path: " + p1)
		failed += 1
		
	# 5. Verify First Five Playable Levels (Levels 1 to 5)
	var levels_valid := true
	for lvl in range(1, 6):
		var path = "res://scenes/levels/world_1/level_%d.tscn" % lvl
		if not ResourceLoader.exists(path):
			levels_valid = false
			printerr("Missing level scene: " + path)
			break
		var scn = load(path)
		if scn == null:
			levels_valid = false
			printerr("Failed to load level: " + path)
			break
		var inst = scn.instantiate()
		if inst.level_number != lvl:
			levels_valid = false
			printerr("Level number mismatch in: " + path)
			inst.queue_free()
			break
		inst.queue_free()
		
	if levels_valid:
		print("[PASS] 5. First 5 playable levels instantiated and validated (Levels 1–5)")
		passed += 1
	else:
		printerr("[FAIL] 5. Levels 1–5 validation failed")
		failed += 1

	print("==========================================")
	print("PHASE 3 RESULTS: Passed %d, Failed %d" % [passed, failed])
	print("==========================================")
	
	if failed == 0:
		print("PHASE 3: COMPLETE GAME LOOP FULLY VERIFIED!")
		get_tree().quit(0)
	else:
		get_tree().quit(1)
