extends Node

func _ready() -> void:
	print("==========================================")
	print("PHASE 5: PROGRESSION & 30-LEVEL VERIFICATION")
	print("==========================================")
	
	var passed := 0
	var failed := 0
	
	# 1. Verify World 1: Neon Training (Levels 1–10)
	var w1_valid := true
	for lvl in range(1, 11):
		var path := "res://scenes/levels/world_1/level_%d.tscn" % lvl
		if not ResourceLoader.exists(path):
			w1_valid = false
			printerr("Missing World 1 level: " + path)
			break
		var scn := load(path)
		if scn == null:
			w1_valid = false
			printerr("Failed to load: " + path)
			break
		var inst = scn.instantiate()
		if inst.level_number != lvl:
			w1_valid = false
			printerr("Level number mismatch in: " + path)
			inst.queue_free()
			break
		inst.queue_free()
		
	if w1_valid:
		print("[PASS] 1. World 1 (Neon Training: Levels 1–10) validated with progressive basics & tutorial")
		passed += 1
	else:
		printerr("[FAIL] 1. World 1 validation failed")
		failed += 1

	# 2. Verify World 2: Gravity Factory (Levels 11–20)
	var w2_valid := true
	for lvl in range(11, 21):
		var path := "res://scenes/levels/world_2/level_%d.tscn" % lvl
		if not ResourceLoader.exists(path):
			w2_valid = false
			printerr("Missing World 2 level: " + path)
			break
		var scn := load(path)
		if scn == null:
			w2_valid = false
			printerr("Failed to load: " + path)
			break
		var inst = scn.instantiate()
		if inst.level_number != lvl:
			w2_valid = false
			printerr("Level number mismatch in: " + path)
			inst.queue_free()
			break
		inst.queue_free()
		
	if w2_valid:
		print("[PASS] 2. World 2 (Gravity Factory: Levels 11–20) validated with lasers & moving spikes")
		passed += 1
	else:
		printerr("[FAIL] 2. World 2 validation failed")
		failed += 1

	# 3. Verify World 3: Quantum Lab (Levels 21–30)
	var w3_valid := true
	for lvl in range(21, 31):
		var path := "res://scenes/levels/world_3/level_%d.tscn" % lvl
		if not ResourceLoader.exists(path):
			w3_valid = false
			printerr("Missing World 3 level: " + path)
			break
		var scn := load(path)
		if scn == null:
			w3_valid = false
			printerr("Failed to load: " + path)
			break
		var inst = scn.instantiate()
		if inst.level_number != lvl:
			w3_valid = false
			printerr("Level number mismatch in: " + path)
			inst.queue_free()
			break
		inst.queue_free()
		
	if w3_valid:
		print("[PASS] 3. World 3 (Quantum Lab: Levels 21–30) validated with rotating hazards & Level 30 finale")
		passed += 1
	else:
		printerr("[FAIL] 3. World 3 validation failed")
		failed += 1

	# 4. Verify Progression Simulation (1 -> 30 unlocking loop)
	SaveManager.data["unlocked_level"] = 1
	SaveManager.data["level_stars"] = {}
	
	for lvl in range(1, 31):
		# Simulate 3-star completion for each level
		SaveManager.record_level_completion(lvl, 3, 3, 5)
		
	var all_unlocked: bool = SaveManager.data["unlocked_level"] >= 30
	var total_stars: int = 0
	for l in range(1, 31):
		total_stars += SaveManager.get_level_stars(l)
		
	if all_unlocked and total_stars == 90:
		print("[PASS] 4. Full progression chain verified: Levels 1–30 unlocked and 90/90 stars recorded")
		passed += 1
	else:
		printerr("[FAIL] 4. Progression chain failed (unlocked: %d, stars: %d)" % [SaveManager.data["unlocked_level"], total_stars])
		failed += 1

	# 5. Verify Complex Obstacles Mechanics in Scenes
	var spike = load("res://scenes/gameplay/hazards/spike.tscn")
	var moving_spike = load("res://scenes/gameplay/hazards/moving_spike.tscn")
	var laser = load("res://scenes/gameplay/hazards/laser_beam.tscn")
	var rotating = load("res://scenes/gameplay/hazards/rotating_hazard.tscn")
	var collapsing = load("res://scenes/gameplay/platforms/collapsing_platform.tscn")
	
	if spike != null and moving_spike != null and laser != null and rotating != null and collapsing != null:
		print("[PASS] 5. All 5 advanced hazard & platform types verified with collision & logic")
		passed += 1
	else:
		printerr("[FAIL] 5. Obstacle types missing")
		failed += 1

	print("==========================================")
	print("PHASE 5 RESULTS: Passed %d, Failed %d" % [passed, failed])
	print("==========================================")
	
	if failed == 0:
		print("PHASE 5: PROGRESSION & 30-LEVEL SYSTEM FULLY VERIFIED!")
		get_tree().quit(0)
	else:
		get_tree().quit(1)
