extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var ceiling: StaticBody2D = $Ceiling
@onready var floor_node: StaticBody2D = $Floor
@onready var hazards_container: Node2D = $Hazards
@onready var platforms_container: Node2D = $Platforms
@onready var collectibles_container: Node2D = $Collectibles

# HUD nodes
@onready var distance_label: Label = $HUD/TopBar/HBox/DistanceLabel
@onready var best_label: Label = $HUD/TopBar/HBox/BestLabel
@onready var pause_btn: Button = $HUD/TopBar/HBox/PauseBtn

# Game Over nodes
@onready var game_over_overlay: CanvasLayer = $GameOverModal
@onready var go_distance_label: Label = $GameOverModal/Panel/VBox/DistanceLabel
@onready var go_best_label: Label = $GameOverModal/Panel/VBox/BestLabel
@onready var new_best_banner: Label = $GameOverModal/Panel/VBox/NewBestBanner
@onready var retry_btn: Button = $GameOverModal/Panel/VBox/RetryBtn
@onready var menu_btn: Button = $GameOverModal/Panel/VBox/MenuBtn

# Preloaded hazard & platform scenes
var spike_scene: PackedScene = preload("res://scenes/gameplay/hazards/spike.tscn")
var moving_spike_scene: PackedScene = preload("res://scenes/gameplay/hazards/moving_spike.tscn")
var laser_scene: PackedScene = preload("res://scenes/gameplay/hazards/laser_beam.tscn")
var rotating_scene: PackedScene = preload("res://scenes/gameplay/hazards/rotating_hazard.tscn")
var platform_scene: PackedScene = preload("res://scenes/gameplay/platforms/platform.tscn")
var collapsing_scene: PackedScene = preload("res://scenes/gameplay/platforms/collapsing_platform.tscn")
var orb_scene: PackedScene = preload("res://scenes/gameplay/collectibles/energy_orb.tscn")

var next_spawn_x: float = 1200.0
const CHUNK_WIDTH: float = 700.0
const SPAWN_AHEAD_DISTANCE: float = 2400.0
const CLEANUP_BEHIND_DISTANCE: float = 1400.0

var current_distance_m: int = 0
var best_distance_m: int = 0
var base_speed: float = 380.0
var max_speed: float = 560.0

func _ready() -> void:
	AudioManager.play_music()
	GameState.is_game_active = true
	GameState.is_paused = false
	get_tree().paused = false
	
	best_distance_m = int(SaveManager.data.get("endless_high_score", 0))
	best_label.text = "BEST: %dm" % best_distance_m
	
	pause_btn.pressed.connect(_on_pause_pressed)
	retry_btn.pressed.connect(_on_retry_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	
	game_over_overlay.visible = false
	new_best_banner.visible = false
	
	GameState.player_died.connect(_on_player_died)
	
	# Spawn initial runway
	for i in range(4):
		_spawn_next_chunk()

func _physics_process(delta: float) -> void:
	if not player or not is_instance_valid(player) or not player.get("is_alive"):
		return
		
	# Follow player with camera
	var target_x: float = player.position.x + 180.0
	camera.position.x = lerp(camera.position.x, target_x, delta * 14.0)
	
	# Keep floor & ceiling centered under player
	floor_node.position.x = player.position.x
	ceiling.position.x = player.position.x
	
	# Update distance & speed scaling
	current_distance_m = int(player.position.x / 100.0)
	distance_label.text = "%d m" % current_distance_m
	
	var speed_boost: float = minf(float(current_distance_m) * 0.18, max_speed - base_speed)
	player.set("move_speed", base_speed + speed_boost)
	
	# Spawn chunks ahead
	if player.position.x + SPAWN_AHEAD_DISTANCE > next_spawn_x:
		_spawn_next_chunk()
		
	# Clean up distant chunks
	_cleanup_old_entities()

func _spawn_next_chunk() -> void:
	var chunk_start: float = next_spawn_x
	var difficulty: int = clampi(int(current_distance_m / 150), 0, 5)
	var pattern: int = randi() % (difficulty + 2)
	
	match pattern:
		0:
			# Breather with floating orbs
			var orb := orb_scene.instantiate()
			orb.position = Vector2(chunk_start + 250.0, 650.0)
			collectibles_container.add_child(orb)
		1:
			# Alternating floor and ceiling spikes
			var s1 := spike_scene.instantiate()
			s1.position = Vector2(chunk_start + 200.0, 1044.0)
			hazards_container.add_child(s1)
			
			var s2 := spike_scene.instantiate()
			s2.position = Vector2(chunk_start + 450.0, 256.0)
			s2.rotation = PI
			hazards_container.add_child(s2)
		2:
			# Floating platform with spikes beneath
			var plat := platform_scene.instantiate()
			plat.position = Vector2(chunk_start + 350.0, 650.0)
			platforms_container.add_child(plat)
			
			var sp := spike_scene.instantiate()
			sp.position = Vector2(chunk_start + 350.0, 1044.0)
			hazards_container.add_child(sp)
		3:
			# Timed laser beam
			var laser := laser_scene.instantiate()
			laser.position = Vector2(chunk_start + 350.0, 650.0)
			laser.set("is_timed", true)
			hazards_container.add_child(laser)
		4:
			# Moving spike oscillation
			var ms := moving_spike_scene.instantiate()
			ms.position = Vector2(chunk_start + 300.0, 520.0)
			hazards_container.add_child(ms)
		5:
			# Rotating hazard + collapsing platform
			var rot := rotating_scene.instantiate()
			rot.position = Vector2(chunk_start + 280.0, 650.0)
			hazards_container.add_child(rot)
			
			var cp := collapsing_scene.instantiate()
			cp.position = Vector2(chunk_start + 500.0, 750.0)
			platforms_container.add_child(cp)
		_:
			# Default floor spike pair
			var sp1 := spike_scene.instantiate()
			sp1.position = Vector2(chunk_start + 250.0, 1044.0)
			hazards_container.add_child(sp1)
			
	next_spawn_x += CHUNK_WIDTH

func _cleanup_old_entities() -> void:
	var threshold: float = player.position.x - CLEANUP_BEHIND_DISTANCE
	for container in [hazards_container, platforms_container, collectibles_container]:
		for child in container.get_children():
			if child.position.x < threshold:
				child.queue_free()

func _on_player_died(_reason: String) -> void:
	GameState.is_game_active = false
	
	# Check distance achievements
	if current_distance_m >= 250:
		AchievementManager.unlock("endless_250")
	if current_distance_m >= 500:
		AchievementManager.unlock("endless_500")
		
	# High score
	var is_new_best: bool = false
	if current_distance_m > best_distance_m:
		best_distance_m = current_distance_m
		SaveManager.data["endless_high_score"] = best_distance_m
		SaveManager.save_game()
		is_new_best = true
		
	go_distance_label.text = "Distance: %d m" % current_distance_m
	go_best_label.text = "Best Record: %d m" % best_distance_m
	new_best_banner.visible = is_new_best
	
	game_over_overlay.visible = true

func _on_pause_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.toggle_pause()

func _on_retry_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/gameplay/endless_mode.tscn")

func _on_menu_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.go_to_main_menu()
