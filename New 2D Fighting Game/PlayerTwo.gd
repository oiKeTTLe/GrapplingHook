extends KinematicBody2D

var friction = false
var UP = Vector2(0, -1)
var gravity = 20
var tapcountright = 0
var tapcountleft = 0
var double_tap = 0
var can_doubletap = true
var is_dashing = false
var can_dash = true
var dash_direction : Vector2
var speed = 300
const jump = -500
const secondjump = -300
const resistance = Vector2(0, -1)
var dashspeed = 1000
var doublejumps = 1
var motion = Vector2()
var dashcooldown = 1
var dashlength = 0.2
onready var dashcooldowntimer = $dashcooldown
onready var dashlengthtimer = $dashlength


func get_direction_from_input():
	var move_dir = Vector2()
	move_dir.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("p1_right")
	#move_dir.y = Input.get_action_strength("p1_down") - Input.get_action_strength("p1_up")
	move_dir = move_dir.clamped(1)
	if (move_dir == Vector2(0, 0)):
		if($AnimatedSprite.flip_h):
			move_dir.x = -1
		else:
			move_dir.x = 1
	return move_dir * dashspeed
	

func _process(delta):
	double_tap += delta
	if double_tap > 0.8:
		
		can_doubletap = false
		double_tap = 0
		tapcountleft = 0
		tapcountright = 0
	else:
		can_doubletap = true

func handle_dash():
	if Input.is_action_just_pressed("p2_dash") and can_dash == true:
		is_dashing = true
		can_dash = false
		dashcooldowntimer.start(dashcooldown)
		dash_direction = get_direction_from_input()
		dashlengthtimer.start(dashlength)

func _physics_process(delta):
	motion.y += gravity
	if Input.is_action_just_pressed("ui_right"):
		tapcountright += 1
	if Input.is_action_just_pressed("ui_left"):
		tapcountleft += 1
	if Input.is_action_pressed("ui_right"):
		friction = false
		#if can_doubletap == true and tapcountright >= 2:
			#is_dashing = true
		$Sword.set_scale(Vector2(2,2))
		$Sword.position.x = 15
		$Sword.rotation_degrees = 9.4
		motion.x = speed
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.play("Running")
	elif Input.is_action_pressed("ui_left"):
		friction = false
		$Sword.set_scale(Vector2(-2,2))
		$Sword.position.x = -15
		$Sword.rotation_degrees = -9.4
		motion.x = -speed
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.play("Running")
	else:
		motion.x = 0
		$AnimatedSprite.play("Idle")
		friction = true
	doublejumps = clamp(doublejumps, 0, 1)
	if is_dashing == true:
		motion = move_and_slide(dash_direction, UP)
		speed = 0
		gravity = 0
	else:
		speed = 300
		gravity = 20
		motion = move_and_slide(motion, resistance)
	if Input.is_action_just_pressed("p2_dash"):
		handle_dash()
	if is_on_floor():
		doublejumps += 1
		if Input.is_action_just_pressed("p2_jump"):
			motion.y = jump
		if Input.is_action_just_pressed("p2_attack"):
			$AnimatedSprite.play("MidPunch")
		elif Input.is_action_pressed("p2_block"):
			$AnimatedSprite.play("Block")
	else:
		if Input.is_action_just_pressed("p2_jump") and doublejumps == 1:
			motion.y = secondjump
			doublejumps -= 1
			if friction == true:
				motion.x = lerp(motion.x, 0, 0.05)
	if friction == true:
		motion.x = lerp(motion.x, 0, 0.2)
var is_inside = false


func _on_Area2D_body_entered(body):
	if body.name == "PlayerOne":
		is_inside = true


func _on_Area2D_body_exited(body):
	if body.name == "PlayerOne":
		is_inside = false


func _on_dashcooldown_timeout():
	can_dash = true


func _on_dashlength_timeout():
	is_dashing = false
