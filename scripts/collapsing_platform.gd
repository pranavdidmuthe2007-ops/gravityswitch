extends StaticBody2D

@export var collapse_delay: float = 0.55
@export var respawn_time: float = 2.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var detector: Area2D = $TriggerArea
@onready var visual: Node2D = $Visual

var is_triggered: bool = false
var initial_pos: Vector2

func _ready() -> void:
	initial_pos = visual.position
	detector.body_entered.connect(_on_trigger_body_entered)

func _on_trigger_body_entered(body: Node2D) -> void:
	if is_triggered:
		return
	if body.is_in_group("player"):
		is_triggered = true
		_shake_and_collapse()

func _shake_and_collapse() -> void:
	# Shake effect
	var tween := create_tween()
	for i in range(5):
		var offset := Vector2(randf_range(-3, 3), randf_range(-2, 2))
		tween.tween_property(visual, "position", initial_pos + offset, collapse_delay / 10.0)
	tween.tween_property(visual, "position", initial_pos, 0.05)
	tween.tween_callback(_collapse)

func _collapse() -> void:
	collision_shape.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(visual, "modulate:a", 0.0, 0.15)
	tween.tween_interval(respawn_time)
	tween.tween_callback(_respawn)

func _respawn() -> void:
	collision_shape.set_deferred("disabled", false)
	is_triggered = false
	var tween := create_tween()
	tween.tween_property(visual, "modulate:a", 1.0, 0.2)
