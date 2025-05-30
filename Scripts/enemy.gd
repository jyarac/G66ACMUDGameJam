extends CharacterBody2D

@export var speed := 150.0
@export var ProjectileScene: PackedScene

var shots_left := 6

enum Edge { TOP, RIGHT, BOTTOM, LEFT }
var edge: int
var direction: int

func _ready():
	randomize()
	var ms = get_parent().map_size

	# Posición inicial en el perímetro
	edge = randi() % 4
	match edge:
		Edge.TOP:
			position = Vector2(randf_range(0.0, ms.x), 0.0)
		Edge.RIGHT:
			position = Vector2(ms.x, randf_range(0.0, ms.y))
		Edge.BOTTOM:
			position = Vector2(randf_range(0.0, ms.x), ms.y)
		Edge.LEFT:
			position = Vector2(0.0, randf_range(0.0, ms.y))

	# Sentido inicial (1 o -1)
	direction = 1 if randf() < 0.5 else -1

	# Timer para disparos cada segundo
	var shoot_timer = Timer.new()
	shoot_timer.wait_time = 1.0
	shoot_timer.one_shot = false
	shoot_timer.autostart = true
	add_child(shoot_timer)
	shoot_timer.connect("timeout", Callable(self, "_on_shoot_timer"))

	# Timer para cambio de dirección cada 2–5 segundos
	var dir_timer = Timer.new()
	dir_timer.name = "DirectionTimer"
	dir_timer.wait_time = randf_range(2.0, 5.0)
	dir_timer.one_shot = true
	dir_timer.autostart = true
	add_child(dir_timer)
	dir_timer.connect("timeout", Callable(self, "_on_direction_timer"))

func _physics_process(delta):
	var ms = get_parent().map_size

	# Si están muy cerca (<=50px), cambian de dirección
	for e in get_tree().get_nodes_in_group("Enemy"):
		if e != self and position.distance_to(e.position) <= 50.0:
			direction = -direction
			break

	# Movimiento pegado al borde actual
	match edge:
		Edge.TOP, Edge.BOTTOM:
			velocity = Vector2(direction * speed, 0.0)
		Edge.LEFT, Edge.RIGHT:
			velocity = Vector2(0.0, direction * speed)
	move_and_slide()

	# Clamp para que no salgan del mapa
	position.x = clamp(position.x, 0.0, ms.x)
	position.y = clamp(position.y, 0.0, ms.y)

	# Detectar esquina y cambiar al siguiente borde
	var at_corner = false
	var new_edge = edge

	if edge == Edge.TOP and (position.x <= 0.0 or position.x >= ms.x):
		at_corner = true
		new_edge = Edge.LEFT if position.x <= 0.0 else Edge.RIGHT
	elif edge == Edge.BOTTOM and (position.x <= 0.0 or position.x >= ms.x):
		at_corner = true
		new_edge = Edge.LEFT if position.x <= 0.0 else Edge.RIGHT
	elif edge == Edge.LEFT and (position.y <= 0.0 or position.y >= ms.y):
		at_corner = true
		new_edge = Edge.TOP if position.y <= 0.0 else Edge.BOTTOM
	elif edge == Edge.RIGHT and (position.y <= 0.0 or position.y >= ms.y):
		at_corner = true
		new_edge = Edge.TOP if position.y <= 0.0 else Edge.BOTTOM

	if at_corner:
		edge = new_edge
		match edge:
			Edge.TOP, Edge.BOTTOM:
				direction = 1 if position.x <= 0.0 else -1
			Edge.LEFT, Edge.RIGHT:
				direction = 1 if position.y <= 0.0 else -1

func _on_shoot_timer():
	if shots_left <= 0:
		return
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.size() < 2:
		return
	# Seleccionamos el otro enemigo usando sintaxis GDScript
	var target_enemy = enemies[1] if enemies[0] == self else enemies[0]
	var dir = (target_enemy.position - position).normalized()
	var p = ProjectileScene.instantiate()
	p.position = position
	p.velocity = dir * p.initial_speed
	get_parent().add_child(p)
	shots_left -= 1

func _on_direction_timer():
	# Invierte el sentido y reinicia el timer con nuevo intervalo
	direction = -direction
	var dt = $DirectionTimer as Timer
	dt.wait_time = randf_range(3.0, 10.0)
	dt.start()
