extends CharacterBody2D
@export var speed := 200
var facing := Vector2.RIGHT

func _physics_process(delta):
	# Movimiento y máscara de entrada
	var input_vec = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	).normalized()
	if input_vec != Vector2.ZERO:
		facing = input_vec
	velocity = input_vec * speed
	move_and_slide()
