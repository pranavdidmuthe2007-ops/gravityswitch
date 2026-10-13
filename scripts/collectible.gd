extends Area2D

@onready var visual: Node2D = $Visual
@onready var particles: CPUParticles2D = $CPUParticles2D

var initial_y: float = 0.0
var time_offset: float = 0.0
var is_collected: bool = false

func _ready() -> void:
	initial_y = position.y
	time_offset = randf() * 10.0
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if not is_collected:
		var t := Time.get_ticks_msec() / 1000.0 + time_offset
		visual.position.y = sin(t * 3.5) * 6.0
		visual.rotation = sin(t * 2.0) * 0.2

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body.is_in_group("player"):
		is_collected = true
		GameState.collect_orb()
		if particles and SaveManager.get_setting("particles", true):
			particles.restart()
			particles.emitting = true
		var tween := create_tween()
		tween.tween_property(visual, "scale", Vector2(1.8, 1.8), 0.1)
		tween.parallel().tween_property(visual, "modulate:a", 0.0, 0.15)
		tween.tween_callback(queue_free)
