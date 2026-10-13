extends Area2D

@export var rotation_speed: float = 2.0
@export var hazard_name: String = "Rotating Blade"

@onready var visual: Node2D = $Visual

func _ready() -> void:
	add_to_group("hazards")
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	rotation += rotation_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die("Hit " + hazard_name)
