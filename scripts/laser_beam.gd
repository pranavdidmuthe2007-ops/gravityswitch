extends Area2D

@export var is_timed: bool = false
@export var active_duration: float = 1.8
@export var inactive_duration: float = 1.4
@export var start_delay: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var beam_visual: Node2D = $BeamVisual
@onready var emitter_top: Node2D = $EmitterTop
@onready var emitter_bottom: Node2D = $EmitterBottom

var is_beam_active: bool = true
var timer: float = 0.0

func _ready() -> void:
	add_to_group("hazards")
	body_entered.connect(_on_body_entered)
	timer = -start_delay
	_set_beam_state(true)

func _process(delta: float) -> void:
	if not is_timed:
		return
		
	timer += delta
	if is_beam_active:
		if timer >= active_duration:
			timer = 0.0
			_set_beam_state(false)
	else:
		# Warning flicker before activating
		if timer >= inactive_duration - 0.4:
			beam_visual.visible = fmod(timer, 0.1) < 0.05
		if timer >= inactive_duration:
			timer = 0.0
			_set_beam_state(true)

func _set_beam_state(active: bool) -> void:
	is_beam_active = active
	collision_shape.set_deferred("disabled", not active)
	beam_visual.visible = active

func _on_body_entered(body: Node2D) -> void:
	if is_beam_active and body.is_in_group("player") and body.has_method("die"):
		body.die("Hit Laser Beam")
