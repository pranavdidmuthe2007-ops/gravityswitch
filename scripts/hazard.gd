extends Area2D
class_name Hazard

@export var hazard_name: String = "Spike"

func _ready() -> void:
	add_to_group("hazards")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die("Hit " + hazard_name)
