extends CharacterBody2D

@export var move_speed := 150.0
@export var ProjectileScene: PackedScene

var shots_left := 6
var target_point := Vector2.ZERO

func _ready():
	randomize()
	_choose_new_target()
	var t = Timer.new()
	t.wait_time = 1.0
	t.autostart = true
	t.one_shot = false
	add_child(t)
	# Godot 4: connect() recibe el nombre de la señal y un Callable
	t.connect("timeout", Callable(self, "_on_shoot_timer"))

func _physics_process(delta):
	# Moverse hacia el target en el perímetro
	var dir = (target_point - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()
	if global_position.distance_to(target_point) < 8.0:
		_choose_new_target()

func _choose_new_target():
	var ms = get_parent().map_size
	match randi() % 4:
		0:
			target_point = Vector2(randf_range(0.0, ms.x), 0.0)
		1:
			target_point = Vector2(ms.x,           randf_range(0.0, ms.y))
		2:
			target_point = Vector2(randf_range(0.0, ms.x), ms.y)
		3:
			target_point = Vector2(0.0,            randf_range(0.0, ms.y))

func _on_shoot_timer():
	if shots_left <= 0:
		return
	# Dispara contra el otro enemigo vivo
