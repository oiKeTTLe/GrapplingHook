extends KinematicBody2D
# - get_viewport().size * 0.5
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
var speed = 500
const jump = -500
const secondjump = -400
const resistance = Vector2(0, -1)
const CHAIN_PULL = 70
var dashspeed = 1500
var doublejumps = 1
var motion = Vector2()
var dashcooldown = 1
var dashlength = 0.2
var chain_velocity := Vector2(0,0)
onready var dashcooldowntimer = $dashcooldown
onready var dashlengthtimer = $dashlength
var can_shoot_chain = 1


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_RIGHT:
			# We clicked the mouse -> shoot()
			$Chain.shoot(event.position - get_viewport().size * 0.5)
			(chain_velocity.x + chain_velocity.y) / 2 + 1
			print(self.position.x, " self position")
			print(speed, " speed")
			
			print(motion.y, " motion.y")
			var a = self.position.x - $Chain/Tip.position.x
			var b = (chain_velocity.x + chain_velocity.y) / 2 + 100
			motion = Vector2(a * speed * b, motion.y).normalized()
			print("New chain velocity (multiplier): " + str(b))
			print("self.position.x = " + str(self.position.x))
			print("speed = " + str(speed))
			print("chain_velocity = " + str(chain_velocity))
			print("motion.y = " + str(motion.y))
			print("New chain velocity (multiplier) = " + str(b))
			print("Vector X calculation = " + str(a * speed * b))
			print("Vector2 = " + str(Vector2(a * speed * b, motion.y).normalized()))
		else:
			# We released the mouse -> release()
			$Chain.release()


func get_direction_from_input():
	var move_dir = Vector2()
	move_dir.x = -Input.get_action_strength("p1_left") + Input.get_action_strength("p1_right")
	#move_dir.y = Input.get_action_strength("p1_down") - Input.get_action_strength("p1_up")
	move_dir = move_dir.clamped(1)
	if (move_dir == Vector2(0, 0)):
		if($AnimatedSprite.flip_h):
			move_dir.x = -1
		else:
			move_dir.x = 1
	return move_dir * dashspeed
	

func _process(delta):
	can_shoot_chain = clamp(can_shoot_chain, 0, 1)
	double_tap += delta
	if double_tap > 0.8:
		
		can_doubletap = false
		double_tap = 0
		tapcountleft = 0
		tapcountright = 0
	else:
		can_doubletap = true

func handle_dash():
	if Input.is_action_just_pressed("p1_dash") and can_dash == true:
		is_dashing = true
		can_dash = false
		dashcooldowntimer.start(dashcooldown)
		dash_direction = get_direction_from_input()
		dashlengthtimer.start(dashlength)

func _physics_process(delta):
	motion.y += gravity
	if Input.is_action_just_pressed("p1_right"):
		tapcountright += 1
	if Input.is_action_just_pressed("p1_left"):
		tapcountleft += 1
	if Input.is_action_pressed("p1_right"):
		friction = false
		#if can_doubletap == true and tapcountright >= 2:
			#is_dashing = true
		$Sword.set_scale(Vector2(2,2))
		$Sword.position.x = 15
		$Sword.rotation_degrees = 9.4
		motion.x = speed
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.play("Running")
	elif Input.is_action_pressed("p1_left"):
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
	if Input.is_action_just_pressed("p1_dash"):
		$ghosttimer.start()
		handle_dash()
	if $Chain.hooked:
		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		chain_velocity = to_local($Chain.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.55
		else:
			# Pulling up is stronger
			chain_velocity.y *= 1.1
		var walk = (Input.get_action_strength("p1_right") - Input.get_action_strength("p1_left")) * speed
		if sign(chain_velocity.x) != sign(walk):
			# if we are trying to walk in a different
			# direction than the chain is pulling
			# reduce its pull
			chain_velocity.x *= 0.7
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	motion += chain_velocity
	
	if is_on_floor():
		doublejumps += 1
		if Input.is_action_just_pressed("p1_jump"):
			motion.y = jump
		if Input.is_action_just_pressed("p1_attack"):
			$AnimatedSprite.play("MidPunch")
			if is_inside == true:
				if get_node("/root/TestLevel/PlayerTwo/AnimatedSprite").animation != "Block":
					get_node("/root/TestLevel/CanvasLayer/FightUI/Player2Health").value -= 10
		elif Input.is_action_pressed("p1_block"):
			$AnimatedSprite.play("Block")
	else:
		if Input.is_action_just_pressed("p1_jump") and doublejumps == 1:
			motion.y = secondjump
			doublejumps -= 1
			if friction == true:
				motion.x = lerp(motion.x, 0, 0.05)
	if friction == true:
		motion.x = lerp(motion.x, 0, 0.2)
var is_inside = false


func _on_Area2D_body_entered(body):
	if body.name == "PlayerTwo":
		is_inside = true


func _on_Area2D_body_exited(body):
	if body.name == "PlayerTwo":
		is_inside = false


func _on_dashcooldown_timeout():
	can_dash = true


func _on_dashlength_timeout():
	$ghosttimer.stop()
	is_dashing = false


func _on_ghosttimer_timeout():
	if is_dashing == true:
		var this_ghost = preload("res://Ghost.tscn").instance()
		get_parent().get_parent().add_child(this_ghost)
		this_ghost.position = position
		this_ghost.texture = $AnimatedSprite.frames.get_frame($AnimatedSprite.animation, $AnimatedSprite.frame)
		this_ghost.scale = Vector2(2, 2)
		this_ghost.flip_h = $AnimatedSprite.flip_h
