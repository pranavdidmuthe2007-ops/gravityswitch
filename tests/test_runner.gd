extends SceneTree

var tests_passed: int = 0
var tests_failed: int = 0

func _init() -> void:
	print("==========================================")
	print("GRAVITY SWITCH AUTOMATED TEST SUITE")
	print("==========================================")
	
	test_audio_manager()
	test_save_manager_and_persistence()
	test_game_state_logic()
	test_player_mechanics()
	test_hazards_and_collectibles()
	test_all_30_levels_integrity()
	
	print("==========================================")
	print("TEST RESULTS SUMMARY:")
	print("Passed: %d, Failed: %d" % [tests_passed, tests_failed])
	print("==========================================")
	
	if tests_failed == 0:
		print("ALL TESTS PASSED SUCCESSFULLY!")
		quit(0)
	else:
		print("SOME TESTS FAILED!")
		quit(1)

func assert_true(condition: bool, test_name: String) -> void:
	if condition:
		print("[PASS] " + test_name)
		tests_passed += 1
	else:
		printerr("[FAIL] " + test_name)
		tests_failed += 1

func test_audio_manager() -> void:
	print("\n--- Testing Procedural Audio Synthesizer ---")
	var am = root.get_node_or_null("AudioManager")
	assert_true(am != null, "AudioManager Autoload exists")
	if am:
		assert_true(am.sfx_streams.has("switch_up"), "Audio SFX 'switch_up' generated")
		assert_true(am.sfx_streams.has("switch_down"), "Audio SFX 'switch_down' generated")
		assert_true(am.sfx_streams.has("orb"), "Audio SFX 'orb' generated")
		assert_true(am.sfx_streams.has("death"), "Audio SFX 'death' generated")
		assert_true(am.sfx_streams.has("win"), "Audio SFX 'win' generated")
		assert_true(am.sfx_streams.has("click"), "Audio SFX 'click' generated")
		assert_true(am.music_stream != null and am.music_stream.data.size() > 0, "Ambient music generated and non-empty")

func test_save_manager_and_persistence() -> void:
	print("\n--- Testing Save System & Persistence ---")
	var sm = root.get_node_or_null("SaveManager")
	assert_true(sm != null, "SaveManager Autoload exists")
	if sm:
		sm.record_level_completion(1, 3, 3, 2)
		assert_true(sm.get_level_stars(1) == 3, "Recorded 3 stars for Level 1")
		assert_true(sm.is_level_unlocked(2), "Level 2 unlocked after Level 1 completion")
		assert_true(sm.is_level_unlocked(1), "Level 1 remains unlocked")
		
		# Test settings persistence
		sm.set_setting("haptics", false)
		assert_true(sm.get_setting("haptics") == false, "Setting updated successfully")
		sm.set_setting("haptics", true)
		assert_true(sm.get_setting("haptics") == true, "Setting reverted successfully")

func test_game_state_logic() -> void:
	print("\n--- Testing GameState & Star Calculation ---")
	var gs = root.get_node_or_null("GameState")
	assert_true(gs != null, "GameState Autoload exists")
	if gs:
		gs.start_level(1, 3, 6)
		assert_true(gs.current_level == 1, "Level initialized to 1")
		assert_true(gs.is_game_active == true, "Game state active")
		assert_true(gs.total_orbs == 3, "Orb target set to 3")
		
		# Collect 3 orbs with 4 switches (goal <= 6)
		gs.collect_orb()
		gs.collect_orb()
		gs.collect_orb()
		gs.record_switch(true)
		gs.record_switch(false)
		gs.record_switch(true)
		gs.record_switch(false)
		
		var stars = gs.calculate_stars()
		assert_true(stars == 3, "Perfect score awards 3 stars (completed + all orbs + under budget)")
		
		# Reset and test 1 star
		gs.start_level(1, 3, 2)
		gs.record_switch(true)
		gs.record_switch(false)
		gs.record_switch(true) # Exceeded switch budget, 0 orbs
		var low_stars = gs.calculate_stars()
		assert_true(low_stars == 1, "Base completion awards 1 star when orbs and budget missed")

func test_player_mechanics() -> void:
	print("\n--- Testing Player Physics & Gravity Switching ---")
	var player_scene = load("res://scenes/gameplay/player.tscn")
	assert_true(player_scene != null, "Player scene loaded")
	if player_scene:
		var p = player_scene.instantiate()
		root.add_child(p)
		
		assert_true(p.is_alive == true, "Player starts alive")
		assert_true(p.is_gravity_up == false, "Player starts with normal downward gravity")
		
		# Test gravity switch
		p.switch_gravity()
		assert_true(p.is_gravity_up == true, "Player gravity inverted to UP")
		assert_true(p.can_switch == false, "Switch cooldown activated to prevent double trigger")
		
		# Test death
		p.die("Test hazard hit")
		assert_true(p.is_alive == false, "Player dies properly")
		assert_true(p.velocity == Vector2.ZERO, "Player velocity stopped on death")
		
		p.queue_free()

func test_hazards_and_collectibles() -> void:
	print("\n--- Testing Hazards & Collectibles Scenes ---")
	var spike = load("res://scenes/gameplay/hazards/spike.tscn")
	assert_true(spike != null, "Spike scene exists")
	var moving_spike = load("res://scenes/gameplay/hazards/moving_spike.tscn")
	assert_true(moving_spike != null, "Moving spike scene exists")
	var laser = load("res://scenes/gameplay/hazards/laser_beam.tscn")
	assert_true(laser != null, "Laser beam scene exists")
	var rotating = load("res://scenes/gameplay/hazards/rotating_hazard.tscn")
	assert_true(rotating != null, "Rotating hazard scene exists")
	var orb = load("res://scenes/gameplay/collectibles/energy_orb.tscn")
	assert_true(orb != null, "Energy orb scene exists")
	var portal = load("res://scenes/gameplay/exit_portal.tscn")
	assert_true(portal != null, "Exit portal scene exists")

func test_all_30_levels_integrity() -> void:
	print("\n--- Testing All 30 Level Scenes Integrity ---")
	var missing_levels: int = 0
	for lvl in range(1, 31):
		var world_idx = int((lvl - 1) / 10) + 1
		var path = "res://scenes/levels/world_%d/level_%d.tscn" % [world_idx, lvl]
		if not ResourceLoader.exists(path):
			missing_levels += 1
			printerr("Missing level: " + path)
		else:
			var scn = load(path)
			if scn == null:
				missing_levels += 1
				printerr("Failed to instantiate level: " + path)
	assert_true(missing_levels == 0, "All 30 Level Scenes exist and instantiate cleanly")
