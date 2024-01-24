extends CharacterBody2D

@export var gravity = 10
@export var speed = 1
@export var health = 10
@onready var attack_hitbox = $ShapeCast2D
@onready var Boss_Position = position.x
@onready var ap = $AnimationPlayer
@onready var Attack_1_Range = $Attack_1_range/CollisionShape2D
@onready var Player = get_parent().get_node("Player")
@onready var Attack_1_CD = $Attack_1_CD
@onready var Attack_1_active_CD = $Attack_1_active_CD
@onready var knockback_CD = $Knockback_CD
var state = "idle"
var player_direction
var in_range_of_attack_1
var attack_1_active
var player_position
var target_position
var knockback_dir

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000
	
	if Player.position.x > Boss_Position:
		player_direction = "right"
	elif Player.position.x < Boss_Position:
		player_direction = "left"
	
	if player_direction == "right":
		Attack_1_Range.position.x = 52
		attack_hitbox.scale.x = -2
	elif player_direction == "left":
		Attack_1_Range.position.x = -52
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
	
	if health <= 0:
		pass
	
	if health <= 0:
		get_tree().change_scene_to_file("res://Victory_Screen.tscn")
	
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
	var player_dir = Player.dir
	knockback_dir = player_dir
	state = "knockback"
	knockback_CD.start()
	health = health - 1

func _on_knockback_cd_timeout():
	state = "idle"
