extends CharacterBody2D
class_name Player

@export var move_speed: float = 380.0
@export var gravity_strength: float = 2400.0
@export var max_fall_speed: float = 1400.0
@export var initial_flip_impulse: float = 220.0

var is_gravity_up: bool = false
var is_alive: bool = true
var can_switch: bool = true
var switch_cooldown: float = 0.08
var cooldown_timer: float = 0.0

@onready var trail: Line2D = $Trail
@onready var sprite: Node2D = $SpriteContainer
@onready var switch_particles: CPUParticles2D = $SwitchParticles
@onready var death_particles: CPUParticles2D = $DeathParticles
@onready var gravity_indicator: Polygon2D = $GravityIndicator

const MAX_TRAIL_POINTS: int = 16

func _ready() -> void:
	is_alive = true
	is_gravity_up = false
	velocity = Vector2.ZERO
	if trail:
		trail.clear_points()
		trail.top_level = true
	_update_gravity_indicator()
	
	if Engine.has_singleton("ThemeManager") or get_node_or_null("/root/ThemeManager"):
		var tm = get_node("/root/ThemeManager")
		_apply_theme(tm.get_current_theme())
		tm.theme_changed.connect(_apply_theme)

func _apply_theme(theme_info: Dictionary) -> void:
	var primary: Color = theme_info.get("primary", Color(0, 1, 1))
	var glow: Color = theme_info.get("glow", Color(0, 1, 1, 0.25))
	if sprite:
		var og = sprite.get_node_or_null("OuterGlow")
		if og: og.color = glow
		var br = sprite.get_node_or_null("Border")
		if br: br.default_color = primary
		var ic = sprite.get_node_or_null("InnerCore")
		if ic: ic.color = primary
	if trail:
		trail.default_color = primary
	if switch_particles:
		switch_particles.color = primary

func _physics_process(delta: float) -> void:
	if not is_alive or not GameState.is_game_active:
		return
		
	# Cooldown handling
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			can_switch = true
			
	# Horizontal constant forward motion
	velocity.x = move_speed
	
	# Apply directional gravity
	var current_gravity := -gravity_strength if is_gravity_up else gravity_strength
	velocity.y += current_gravity * delta
	velocity.y = clampf(velocity.y, -max_fall_speed, max_fall_speed)
	
	# Move and slide
	move_and_slide()
	
	# Update visual trail
	_update_trail()
	
	# Visual squash / stretch rotation
	var target_rot: float = PI if is_gravity_up else 0.0
	sprite.rotation = lerp_angle(sprite.rotation, target_rot, delta * 18.0)
	
	# Check boundary falls (if fallen way off screen)
	if position.y < -300 or position.y > 1600:
		die("Fell out of bounds")

func _unhandled_input(event: InputEvent) -> void:
	if not is_alive or not GameState.is_game_active or GameState.is_paused:
		return
		
	if event.is_action_pressed("switch_gravity"):
		switch_gravity()

func switch_gravity() -> void:
	if not can_switch or not is_alive:
		return
		
	can_switch = false
	cooldown_timer = switch_cooldown
	is_gravity_up = not is_gravity_up
	
	# Provide responsive impulse in the new direction
	if is_gravity_up:
		velocity.y = minf(velocity.y, 0.0) - initial_flip_impulse
	else:
		velocity.y = maxf(velocity.y, 0.0) + initial_flip_impulse
		
	GameState.record_switch(is_gravity_up)
	_update_gravity_indicator()
	
	# Particles and squash
	if switch_particles and SaveManager.get_setting("particles", true):
		switch_particles.restart()
		switch_particles.emitting = true
		
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.7, 1.4), 0.04)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.08)

func _update_gravity_indicator() -> void:
	if gravity_indicator:
		gravity_indicator.rotation = PI if is_gravity_up else 0.0
		gravity_indicator.color = Color(1.0, 0.2, 0.6) if is_gravity_up else Color(0.0, 0.9, 1.0)

func _update_trail() -> void:
	if not trail:
		return
	trail.add_point(global_position)
	if trail.get_point_count() > MAX_TRAIL_POINTS:
		trail.remove_point(0)

func die(reason: String = "Lethal hazard hit") -> void:
	if not is_alive:
		return
	is_alive = false
	velocity = Vector2.ZERO
	sprite.visible = false
	if gravity_indicator:
		gravity_indicator.visible = false
	if trail:
		trail.clear_points()
		
	if death_particles and SaveManager.get_setting("particles", true):
		death_particles.restart()
		death_particles.emitting = true
		
	GameState.trigger_death(reason)

func _on_hazard_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("hazards"):
		die("Hit hazard")

func _on_hazard_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("hazards"):
		die("Hit hazard")
