extends CharacterBody2D

@export var speed := 400.0
var facing := Vector2.RIGHT

func _physics_process(delta):
	# 1. Leer input y actualizar facing
	var input_vec = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	).normalized()
	if input_vec != Vector2.ZERO:
		facing = input_vec

	# 2. Actualizar la propiedad velocity
	velocity = input_vec * speed

	# 3. Mover usando el método sin argumentos
	move_and_slide()

	# 4. Limitar dentro de los bordes del mapa
	var ms = get_parent().map_size   # Debe venir de Main.gd: @export var map_size: Vector2
	position.x = clamp(position.x, 0.0, ms.x)
	position.y = clamp(position.y, 0.0, ms.y)
