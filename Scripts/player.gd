extends CharacterBody2D

@export var speed = 200
@export var gravity = 10
@export var jump_force = 300
@export var health = 10
@export var max_health = 10

@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@onready var crouch_raycast1 = $CrouchRaycast_1
@onready var crouch_raycast2 = $CrouchRaycast_2
@onready var attackCD = $CDs/attackCD
@onready var iframeCD = $CDs/iframeCD
@onready var knockbackCD = $CDs/knockbackCD
@onready var attack_hitbox = $BasicAttackHitbox
@onready var charge_attack_tier1 = $ChargedAttackHitbox1

var is_crouching = false
var stuck_under_object = false
var is_attacking = false
var charge_level = 0
var charging = false
var ready_to_charge = false
var readyToChargeTimerActive = false
var chargeTimerActive = false 
var chargeAttackTier1 = false
var dir = 1
var knockback = false
var respawn_point
var iframes = false

var standing_cshape = preload("res://resources/player_standing_cshape.tres")
var crouching_cshape = preload("res://resources/player_crouching_cshape.tres")

func _ready():
	set_health_bar()
	$Camera2D/healthbar.max_value = max_health

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000
	
	if Input.is_action_just_pressed("jump") && is_on_floor():
		if charging == false:
			velocity.y = -jump_force
	
	if Input.is_action_just_pressed("move_left"):
		if knockback == false and charging == false:
			dir = -1
	
	if Input.is_action_just_pressed("move_right"):
		if knockback == false and charging == false:
			dir = 1
	
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	if !charging:
		velocity.x = speed * horizontal_direction
	elif charging == true:
		velocity.x = 0
	
	if horizontal_direction != 0:
		if !is_attacking:
			if charging == false:
				switch_direction(horizontal_direction)
	
	if Input.is_action_just_pressed("crouch"):
		if charging == false:
			crouch()
	elif Input.is_action_just_released("crouch"):
		if above_head_is_empty():
			stand()
		else:
			if stuck_under_object != true:
				stuck_under_object = true
	
	if stuck_under_object && above_head_is_empty():
		if !Input.is_action_pressed("crouch"):
			stand()
			stuck_under_object = false
	
	if is_crouching == false && is_attacking == false:
		if Input.is_action_just_pressed("attack"):
			if readyToChargeTimerActive == false:
				$CDs/chargeStartTimer.start()
				readyToChargeTimerActive = true
			if ready_to_charge == true:
				charging = true
				charge_level = 0
				print(charging)
		if Input.is_action_just_released("attack") and charge_level == 0:
			if charging:
				attack()
				charge_level = 0
				charging = false
			else:
				attack()
				charge_level = 0
				charging = false
		if Input.is_action_just_released("attack") and charge_level > 0:
			chargeAttackTier1 = true
			charging = false
			charge_level = 0
	
	if charging == false:
		$ChargeAttackDust.emitting = false
		$ChargeAttackDust2.emitting = false
		$ChargeAttackPillar.emitting = false
		$ChargeAttackPillar2.emitting = false
		$ChargeAttackSword.emitting = false
		$Sprite2D.position.x = 0
	
	if dir == 1:
		charge_attack_tier1.position.x = 0
		if charge_level > 0:
			$ChargeAttackSword.gravity.x = -1100
			$Sprite2D.position.x = -5
	if dir == -1:
		charge_attack_tier1.position.x = -160
		if charge_level > 0:
			$ChargeAttackSword.gravity.x = 1100
			$Sprite2D.position.x = 5
	
	if charging:
		if charge_level == 0 and chargeTimerActive == false:
			charge_attack()
		elif charge_level == 1 and chargeTimerActive == false:
			charge_attack()
		elif charge_level == 2 and chargeTimerActive == false:
			charge_attack()
		elif charge_level == 3 and chargeTimerActive == false:
			pass
	
	if chargeAttackTier1 == true:
		_charge_attack1_damage()
	
	if knockback == true:
		$Sprite2D.modulate = Color(255,0,0)
		velocity.y = -100
		velocity.x = 300 * -dir
	elif knockback == false:
		$Sprite2D.modulate = Color(1,1,1)
	
	if health <= 0:
		get_tree().change_scene_to_file("res://main_menu.tscn")
	
	move_and_slide()
	update_animations(horizontal_direction)

func above_head_is_empty() -> bool:
	var result = !crouch_raycast1.is_colliding() && !crouch_raycast2.is_colliding()
	return result

func update_animations(horizontal_direction):
	if knockback == true:
		ap.play("knockback")
	elif is_attacking:
		if is_on_floor():
			ap.play("attack")
		if !is_on_floor():
			ap.play("attack_air")
	elif charging == true:
		if charge_level == 1:
			ap.play("Charge_attack_charging_1")
		elif charge_level == 2:
			ap.play("Charge_attack_charging_2")
		elif charge_level == 3:
			ap.play("Charge_attack_charging_3")
	else:
		if is_attacking == false:
			if is_on_floor():
				if horizontal_direction == 0:
					if is_crouching:
						ap.play("crouch")
					else:
						ap.play("idle")
				else:
					if is_crouching:
						ap.play("crouch_walk")
					else:
						ap.play("run")
			else:
				if is_crouching == false:
					if velocity.y < 0:
						ap.play("jump")
					if velocity.y > 0:
						ap.play("fall")

func switch_direction(horizontal_direction):
	if knockback == false:
		sprite.flip_h = (horizontal_direction == -1)
		sprite.position.x = horizontal_direction * 4
		if sprite.flip_h == false:
			attack_hitbox.scale.x = -2
		elif sprite.flip_h == true:
			attack_hitbox.scale.x = 2

func crouch():
	if is_crouching:
		return
	is_crouching = true
	cshape.shape = crouching_cshape
	cshape.position.y = 29

func stand():
	if is_crouching == false:
		return
	is_crouching = false
	cshape.shape = standing_cshape
	cshape.position.y = 21

func attack():
	if is_attacking:
		return
	else:
		if attack_hitbox.is_colliding():
			var thing_being_hit = attack_hitbox.get_collider(0)
			if thing_being_hit.has_method("hurt"):
				thing_being_hit.hurt()
		attackCD.start()
		is_attacking = true

func _on_attack_cd_timeout():
	is_attacking = false

func _charge_attack_tier1():
	chargeAttackTier1 = true
	$CDs/chargeAttackTier1CD.start()

func _charge_attack1_damage():
	if charge_attack_tier1.has_overlapping_bodies():
		var thing_being_hit = charge_attack_tier1.get_overlapping_bodies()
		if thing_being_hit.has_method("hurt"):
			thing_being_hit.hurt()

func charge_attack():
	if ready_to_charge:
		$CDs/ChargeTimer.start()
		chargeTimerActive = true

func hurt():
	health = health - 1
	set_health_bar()
	knockback = true
	knockbackCD.start()

func _on_knockback_cd_timeout():
	knockback = false

func set_health_bar():
	$Camera2D/healthbar.value = health

func spikes():
	if iframes == false:
		position = respawn_point
		health = health - 1
		set_health_bar()
		iframes = true
		iframeCD.start()

func _on_iframe_cd_timeout():
	iframes = false

func _on_charge_timer_timeout():
	if charge_level < 4:
		charge_level = charge_level + 1
	chargeTimerActive = false
	print(charge_level)

func _on_charge_start_timer_timeout():
	if ready_to_charge == false:
		ready_to_charge = true
	readyToChargeTimerActive = false
	print("ready to charge")

func _on_charge_attack_tier_1cd_timeout():
	chargeAttackTier1 = false
