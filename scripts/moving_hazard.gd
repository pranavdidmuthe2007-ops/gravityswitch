extends Area2D

@export var move_distance: Vector2 = Vector2(0, 120)
@export var cycle_time: float = 2.0
@export var hazard_name: String = "Moving Spike"

var start_pos: Vector2

func _ready() -> void:
	add_to_group("hazards")
	body_entered.connect(_on_body_entered)
	start_pos = position
	_start_movement()

func _start_movement() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "position", start_pos + move_distance, cycle_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", start_pos, cycle_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die("Hit " + hazard_name)
