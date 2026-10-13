extends Node

var tests_passed: int = 0
var tests_failed: int = 0

func _ready() -> void:
	print("==========================================")
	print("GRAVITY SWITCH FULL SYSTEM INTEGRATION TEST SUITE")
	print("==========================================")
	
	test_audio_manager()
	test_save_manager_and_persistence()
	test_game_state_logic()
	test_theme_manager()
	test_achievement_manager()
	test_player_mechanics()
	test_hazards_and_collectibles()
	test_endless_mode_and_extra_scenes()
	test_all_30_levels_integrity()
	
	print("==========================================")
	print("TEST RESULTS SUMMARY:")
	print("Passed: %d, Failed: %d" % [tests_passed, tests_failed])
	print("==========================================")
	
	if tests_failed == 0:
		print("ALL TESTS PASSED WITH 100% SUCCESS!")
		get_tree().quit(0)
	else:
		printerr("SOME TESTS FAILED!")
		get_tree().quit(1)

func assert_true(condition: bool, test_name: String) -> void:
	if condition:
		print("[PASS] " + test_name)
		tests_passed += 1
	else:
		printerr("[FAIL] " + test_name)
		tests_failed += 1

func test_audio_manager() -> void:
	print("\n--- Testing Procedural Audio Synthesizer ---")
	assert_true(AudioManager != null, "AudioManager Autoload exists")
	if AudioManager:
		assert_true(AudioManager.sfx_streams.has("switch_up"), "Audio SFX 'switch_up' generated")
		assert_true(AudioManager.sfx_streams.has("switch_down"), "Audio SFX 'switch_down' generated")
		assert_true(AudioManager.sfx_streams.has("orb"), "Audio SFX 'orb' generated")
		assert_true(AudioManager.sfx_streams.has("death"), "Audio SFX 'death' generated")
		assert_true(AudioManager.sfx_streams.has("win"), "Audio SFX 'win' generated")
		assert_true(AudioManager.sfx_streams.has("click"), "Audio SFX 'click' generated")
		assert_true(AudioManager.music_stream != null and AudioManager.music_stream.data.size() > 0, "Ambient music generated and non-empty")

func test_save_manager_and_persistence() -> void:
	print("\n--- Testing Save System & Persistence ---")
	assert_true(SaveManager != null, "SaveManager Autoload exists")
	if SaveManager:
		SaveManager.record_level_completion(1, 3, 3, 2)
		assert_true(SaveManager.get_level_stars(1) == 3, "Recorded 3 stars for Level 1")
		assert_true(SaveManager.is_level_unlocked(2), "Level 2 unlocked after Level 1 completion")
		assert_true(SaveManager.is_level_unlocked(1), "Level 1 remains unlocked")
		
		# Test settings persistence
		SaveManager.set_setting("haptics", false)
		assert_true(SaveManager.get_setting("haptics") == false, "Setting updated successfully")
		SaveManager.set_setting("haptics", true)
		assert_true(SaveManager.get_setting("haptics") == true, "Setting reverted successfully")

func test_game_state_logic() -> void:
	print("\n--- Testing GameState & Star Calculation ---")
	assert_true(GameState != null, "GameState Autoload exists")
	if GameState:
		GameState.start_level(1, 3, 6)
		assert_true(GameState.current_level == 1, "Level initialized to 1")
		assert_true(GameState.is_game_active == true, "Game state active")
		assert_true(GameState.total_orbs == 3, "Orb target set to 3")
		
		# Collect 3 orbs with 4 switches (budget <= 6)
		GameState.collect_orb()
		GameState.collect_orb()
		GameState.collect_orb()
		GameState.record_switch(true)
		GameState.record_switch(false)
		GameState.record_switch(true)
		GameState.record_switch(false)
		
		var stars = GameState.calculate_stars()
		assert_true(stars == 3, "Perfect score awards 3 stars (completed + all orbs + under budget)")
		
		# Reset and test 1 star
		GameState.start_level(1, 3, 2)
		GameState.record_switch(true)
		GameState.record_switch(false)
		GameState.record_switch(true) # Exceeded switch budget, 0 orbs
		var low_stars = GameState.calculate_stars()
		assert_true(low_stars == 1, "Base completion awards 1 star when orbs and budget missed")

func test_theme_manager() -> void:
	print("\n--- Testing Theme & Skins System ---")
	assert_true(ThemeManager != null, "ThemeManager Autoload exists")
	if ThemeManager:
		var current = ThemeManager.get_current_theme()
		assert_true(current.has("primary"), "Current theme has primary color")
		assert_true(ThemeManager.is_theme_unlocked("cyber_cyan"), "Default cyber cyan skin is unlocked")
		assert_true(ThemeManager.get_all_themes().size() >= 5, "5 neon themes registered")

func test_achievement_manager() -> void:
	print("\n--- Testing Achievements System ---")
	assert_true(AchievementManager != null, "AchievementManager Autoload exists")
	if AchievementManager:
		assert_true(AchievementManager.ACHIEVEMENTS.size() >= 12, "12 achievements registered")
		AchievementManager.unlock("first_flip")
		assert_true(AchievementManager.is_unlocked("first_flip"), "'first_flip' achievement marked unlocked")

func test_player_mechanics() -> void:
	print("\n--- Testing Player Physics & Gravity Switching ---")
	var player_scene = load("res://scenes/gameplay/player.tscn")
	assert_true(player_scene != null, "Player scene loaded")
	if player_scene:
		var p = player_scene.instantiate()
		add_child(p)
		
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

func test_endless_mode_and_extra_scenes() -> void:
	print("\n--- Testing Endless Mode and Menu Scenes ---")
	var endless = load("res://scenes/gameplay/endless_mode.tscn")
	assert_true(endless != null, "Endless mode scene loads")
	var skins = load("res://scenes/ui/skins_menu.tscn")
	assert_true(skins != null, "Skins menu scene loads")
	var achs = load("res://scenes/ui/achievements_menu.tscn")
	assert_true(achs != null, "Achievements menu scene loads")

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
