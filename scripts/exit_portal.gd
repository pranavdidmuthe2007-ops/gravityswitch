extends Area2D

@onready var ring1: Node2D = $Ring1
@onready var ring2: Node2D = $Ring2
@onready var particles: CPUParticles2D = $CPUParticles2D

var is_activated: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if ring1:
		ring1.rotation += delta * 2.5
	if ring2:
		ring2.rotation -= delta * 3.5

func _on_body_entered(body: Node2D) -> void:
	if is_activated:
		return
	if body.is_in_group("player"):
		is_activated = true
		if particles:
			particles.speed_scale = 3.0
		var tween := create_tween()
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
		tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.3)
		GameState.complete_level()
