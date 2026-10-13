extends Node

signal gravity_switched(is_up: bool)
signal orb_collected(current: int, total: int)
signal player_died(reason: String)
signal level_completed(stars: int, orbs: int, switches: int, time_taken: float)
signal game_paused(paused: bool)

var current_level: int = 1
var is_game_active: bool = false
var is_paused: bool = false

var collected_orbs: int = 0
var total_orbs: int = 3
var switches_used: int = 0
var max_switches_for_star: int = 8
var level_time: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if is_game_active and not is_paused:
		level_time += delta

func start_level(level_num: int, orb_target: int = 3, switch_target: int = 8) -> void:
	current_level = clampi(level_num, 1, 30)
	collected_orbs = 0
	total_orbs = orb_target
	switches_used = 0
	max_switches_for_star = switch_target
	level_time = 0.0
	is_game_active = true
	is_paused = false
	get_tree().paused = false

func record_switch(is_up: bool) -> void:
	if not is_game_active:
		return
	switches_used += 1
	gravity_switched.emit(is_up)
	AudioManager.play_sfx("switch_up" if is_up else "switch_down", randf_range(0.95, 1.05))
	AudioManager.trigger_haptic(30)

func collect_orb() -> void:
	if not is_game_active:
		return
	collected_orbs += 1
	orb_collected.emit(collected_orbs, total_orbs)
	AudioManager.play_sfx("orb", 1.0 + (float(collected_orbs) * 0.1))
	AudioManager.trigger_haptic(45)

func trigger_death(reason: String = "Lethal hazard hit") -> void:
	if not is_game_active:
		return
	is_game_active = false
	AudioManager.play_sfx("death")
	AudioManager.trigger_haptic(80)
	player_died.emit(reason)

func complete_level() -> void:
	if not is_game_active:
		return
	is_game_active = false
	var stars := calculate_stars()
	SaveManager.record_level_completion(current_level, stars, collected_orbs, switches_used)
	AudioManager.play_sfx("win")
	AudioManager.trigger_haptic(60)
	level_completed.emit(stars, collected_orbs, switches_used, level_time)

func calculate_stars() -> int:
	var stars := 1 # Base star for finishing
	if collected_orbs >= total_orbs and total_orbs > 0:
		stars += 1
	if switches_used <= max_switches_for_star:
		stars += 1
	return clampi(stars, 1, 3)

func toggle_pause() -> void:
	set_pause(not is_paused)

func set_pause(paused: bool) -> void:
	is_paused = paused
	get_tree().paused = paused
	game_paused.emit(is_paused)

func get_level_scene_path(level_num: int) -> String:
	var world_num := int((level_num - 1) / 10) + 1
	return "res://scenes/levels/world_%d/level_%d.tscn" % [world_num, level_num]

func load_level(level_num: int) -> void:
	set_pause(false)
	current_level = clampi(level_num, 1, 30)
	var scene_path := get_level_scene_path(current_level)
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		# Fallback to generic game runner
		get_tree().change_scene_to_file("res://scenes/gameplay/game.tscn")

func restart_level() -> void:
	load_level(current_level)

func load_next_level() -> void:
	if current_level < 30:
		load_level(current_level + 1)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

func go_to_level_select() -> void:
	set_pause(false)
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

func go_to_main_menu() -> void:
	set_pause(false)
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
