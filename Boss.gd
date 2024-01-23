extends CharacterBody2D

@export var gravity = 10
@export var speed = 150
@onready var Boss_Position = position.x
@onready var ap = $AnimationPlayer
@onready var Attack_1_Range = $Attack_1_range/CollisionShape2D
@onready var Player = get_parent().get_node("Player")
@onready var Attack_1_CD = $Attack_1_CD
@onready var Attack_1_active_CD = $Attack_1_active_CD
var state = "idle"
var player_direction
var in_range_of_attack_1
var attack_1_active

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
	elif player_direction == "left":
		Attack_1_Range.position.x = -52
	
	if in_range_of_attack_1 == true:
		if state == "idle":
			attack_1()
	elif in_range_of_attack_1 == false:
		if state == "idle":
			chase()
	
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

func _on_attack_1_range_body_entered(body):
	if body.is_in_group("Player"):
		in_range_of_attack_1 = true

func _on_attack_1_range_body_exited(body):
	if body.is_in_group("Player"):
		in_range_of_attack_1 = false

func attack_1():
		Attack_1_CD.start()
		Attack_1_active_CD.start()
		attack_1_active = true
		state = "attacking"

func _on_attack_1_cd_timeout():
	state = "idle"
func _on_attack_1_active_cd_timeout():
	state = "stunned"


func chase():
	if !in_range_of_attack_1:
		state = "running"
		velocity.x = speed * -1
	else:
		state = "idle"
