extends CharacterBody2D

var speed = 30
var health = 10
var KnockbackPower = 20
@onready var target = $"../Player"
@onready var CShape = $CollisionShape2D
@onready var ap = $AnimationPlayer
@onready var distance = position.distance_to(target.position)
var aggro_range = 300
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _physics_process(delta):
	if health > 0:
		ap.play("Bat_idle")
		distance = position.distance_to(target.position)
		if target == null:
			get_tree().get_nodes_in_group("player")[0]
		if target != null and distance < aggro_range:
			velocity = position.direction_to(target.position) * speed
			move_and_slide()
	else:
		ap.play("Bat_Dead")
		CShape.scale.y = 0.4
		$".".collision_layer = 4
		$".".collision_mask = 1
		$DeathParticle.emitting = true
		velocity.y += gravity * delta
		move_and_slide()

func switch_direction(horizontal_direction):
	Sprite2D.flip_h = (horizontal_direction == -1)
	Sprite2D.position.x = horizontal_direction * 4

func hurt():
	var KnockbackDirection = -velocity * KnockbackPower
	velocity = KnockbackDirection
	health -= 2
	$DMGparticle.emitting = true
