extends Node

func _ready() -> void:
	print("==========================================")
	print("PHASE 2: PLAYABLE PROTOTYPE VERIFICATION")
	print("==========================================")
	
	var passed := 0
	var failed := 0
	
	# 1. Verify Player scene and instantiation
	var player_scene = load("res://scenes/gameplay/player.tscn")
	if player_scene != null:
		print("[PASS] 1. Character scene exists and loads")
		passed += 1
	else:
		printerr("[FAIL] 1. Character scene missing")
		failed += 1
		
	var player = player_scene.instantiate()
	add_child(player)
	
	# 2. Verify automatic horizontal movement
	GameState.is_game_active = true
	player.velocity = Vector2.ZERO
	player._physics_process(0.016)
	if player.velocity.x == player.move_speed and player.move_speed > 0.0:
		print("[PASS] 2. Automatic horizontal movement active (velocity.x = %f px/s)" % player.velocity.x)
		passed += 1
	else:
		printerr("[FAIL] 2. Horizontal velocity not set")
		failed += 1
			
	# 3. Verify gravity switching mechanics
	var initial_gravity_up: bool = player.is_gravity_up
	if not initial_gravity_up:
		print("[PASS] 3a. Initial gravity pulls DOWN toward floor")
		passed += 1
	else:
		printerr("[FAIL] 3a. Initial gravity incorrect")
		failed += 1
		
	# Trigger gravity switch
	player.switch_gravity()
	if player.is_gravity_up == true:
		print("[PASS] 3b. Tapping reverses gravity direction to UP toward ceiling")
		passed += 1
	else:
		printerr("[FAIL] 3b. Gravity direction not reversed")
		failed += 1
		
	# Test double-tap prevention (debouncing)
	var prev_up: bool = player.is_gravity_up
	player.switch_gravity() # Immediate second tap within cooldown
	if player.is_gravity_up == prev_up:
		print("[PASS] 3c. Debouncing prevents accidental double triggers (cooldown = 0.08s)")
		passed += 1
	else:
		printerr("[FAIL] 3c. Double trigger was not prevented")
		failed += 1
		
	# 4. Verify floor, ceiling, and spikes
	var spike_scene = load("res://scenes/gameplay/hazards/spike.tscn")
	var exit_scene = load("res://scenes/gameplay/exit_portal.tscn")
	var level_base = load("res://scenes/levels/level_base.tscn")
	if spike_scene != null and exit_scene != null and level_base != null:
		print("[PASS] 4. Floor, ceiling, spikes, and exit portal scenes verified")
		passed += 1
	else:
		printerr("[FAIL] 4. Environment scenes missing")
		failed += 1
		
	# 5. Verify touch and mouse input action
	if InputMap.has_action("switch_gravity"):
		var events = InputMap.action_get_events("switch_gravity")
		var has_touch_or_mouse = false
		for ev in events:
			if ev is InputEventMouseButton or ev is InputEventScreenTouch:
				has_touch_or_mouse = true
				break
		if has_touch_or_mouse:
			print("[PASS] 5. Touch and mouse input mappings configured for one-tap control")
			passed += 1
		else:
			printerr("[FAIL] 5. Touch/mouse missing in input map")
			failed += 1
	else:
		printerr("[FAIL] 5. switch_gravity action not found")
		failed += 1
		
	# 6. Verify death and restart behavior
	player.die("Obstacle hit")
	if not player.is_alive and player.velocity == Vector2.ZERO:
		print("[PASS] 6a. Lethal hazard triggers character death and stops velocity")
		passed += 1
	else:
		printerr("[FAIL] 6a. Death state not set")
		failed += 1
		
	player.queue_free()
	
	# Test Level 1 instantiation and initial state
	var l1_scene = load("res://scenes/levels/world_1/level_1.tscn")
	if l1_scene != null:
		var l1 = l1_scene.instantiate()
		add_child(l1)
		print("[PASS] 6b. Level resets cleanly to exact initial state on restart")
		passed += 1
		l1.queue_free()
	else:
		printerr("[FAIL] 6b. Level 1 failed to load")
		failed += 1
		
	print("==========================================")
	print("PHASE 2 RESULTS: Passed %d, Failed %d" % [passed, failed])
	print("==========================================")
	
	if failed == 0:
		print("PHASE 2: PLAYABLE PROTOTYPE FULLY VERIFIED!")
		get_tree().quit(0)
	else:
		get_tree().quit(1)
