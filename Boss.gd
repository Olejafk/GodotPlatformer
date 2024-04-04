extends CharacterBody2D

@export var gravity = 10
@export var speed = 1
@export var health = 10
@export var max_health = 10
@onready var attack_hitbox = $ShapeCast2D
@onready var Boss_Position = position.x
@onready var ap = $AnimationPlayer
@onready var Attack_1_Range = $Attack_1_range/CollisionShape2D
@onready var Player = get_parent().get_node("Player")
@onready var Attack_1_CD = $Attack_1_CD
@onready var Attack_1_active_CD = $Attack_1_active_CD
@onready var knockback_CD = $Knockback_CD
@onready var iframesCD = $iframesCD
var state = "idle"
var player_direction = "left"
var in_range_of_attack_1 = false
var attack_1_active
var player_position
var target_position
var knockback_dir
var iframes = false

func _ready():
	$healthbar.max_value = max_health
	set_health_bar()

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000
	
	if player_direction == "right":
		Attack_1_Range.position.x = 35
		attack_hitbox.scale.x = -2
	elif player_direction == "left":
		Attack_1_Range.position.x = -35
		attack_hitbox.scale.x = 2
	
	if in_range_of_attack_1 == true:
		if state == "idle":
			attack_1()
	if in_range_of_attack_1 == false:
		if state == "idle":
			chase()
	
	if state == "running":
		player_position = Player.position.x
		target_position = (player_position - position.x)
		velocity.x = target_position * speed
	
	if state == "stunned":
		if state != "knockback":
			velocity.x = 0
	
	if state == "knockback":
		velocity.y = -100
		velocity.x = 300 * knockback_dir
	
	if iframes == true:
		$Sprite2D.modulate = Color(255,0,0)
		$BossHeadParticles.modulate = Color(255,0,0)
	elif iframes == false:
		$Sprite2D.modulate = Color(1,1,1)
		$BossHeadParticles.modulate = Color(1,1,1)
	
	if health <= 0:
		get_parent().remove_child($".")
	
	move_and_slide()
	update_animations()


func update_animations():
	if state == "attacking":
		if attack_1_active:
			if player_direction == "left":
				ap.play("Boss_Attack_1_Left")
			if player_direction == "right":
				ap.play("Boss_Attack_1_Right")
	if state == "stunned":
		if player_direction == "left":
				ap.play("Boss_Stunned_Left")
		if player_direction == "right":
				ap.play("Boss_Stunned_Right")
	if state == "running":
		if player_direction == "left":
				ap.play("Boss_Run_Left")
		if player_direction == "right":
				ap.play("Boss_Run_Right")
	if state == "idle":
		if player_direction == "right":
			ap.play("Boss_Idle_Right")
		elif player_direction == "left":
			ap.play("Boss_Idle_Left")
	if state == "knockback":
		if player_direction == "left":
			ap.play("Boss_Hit_Left")
		if player_direction == "right":
			ap.play("Boss_Hit_Right")

func _on_attack_1_range_body_entered(body):
	if body.is_in_group("Player"):
		in_range_of_attack_1 = true
		if state == "running":
			state = "idle"

func _on_attack_1_range_body_exited(body):
	if body.is_in_group("Player"):
		in_range_of_attack_1 = false

func attack_1():
	if velocity.x > 0:
		velocity.x - 50
		if velocity.x < 0:
			velocity.x = 0
	
	if attack_hitbox.is_colliding():
		var thing_being_hit = attack_hitbox.get_collider(0)
		if thing_being_hit.has_method("hurt"):
			thing_being_hit.hurt()
	Attack_1_CD.start()
	Attack_1_active_CD.start()
	attack_1_active = true
	state = "attacking"

func _on_attack_1_cd_timeout():
	state = "idle"
func _on_attack_1_active_cd_timeout():
	state = "stunned"

func chase():
	if in_range_of_attack_1:
		state = "idle"
	if !in_range_of_attack_1:
		state = "running"

func hurt():
	if iframes == false:
		var player_dir = Player.dir
		knockback_dir = player_dir
		state = "knockback"
		iframes = true
		knockback_CD.start()
		iframesCD.start()
		health = health - 1
		set_health_bar()

func _on_knockback_cd_timeout():
	state = "idle"

func _on_player_direction_area_left_body_entered(body):
	if body.is_in_group("Player"):
		player_direction = "left"

func _on_player_direction_area_right_body_entered(body):
	if body.is_in_group("Player"):
		player_direction = "right"

func _on_player_direction_top_body_entered(body):
	if body.is_in_group("Player"):
		player_direction = "top"

func _on_iframes_cd_timeout():
	iframes = false

func set_health_bar():
	$healthbar.value = health
