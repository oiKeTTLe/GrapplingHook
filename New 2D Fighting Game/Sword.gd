extends Area2D
var is_in_body = false
var is_attacking = false
var can_attack = true
onready var swingtimer = $Timer
onready var attacktimer = $Timer2



# warning-ignore:unused_argument
func _process(delta):
	var parentname = get_parent().name
	if parentname == "PlayerOne":
		if Input.is_action_just_pressed("p1_attack") and can_attack == true:
			if get_parent().get_child(1).flip_h == true:
				$AnimationPlayer.play("swingleft")
			else:
				$AnimationPlayer.play("swing")
			can_attack = false
			attacktimer.start()
			swingtimer.start()
			if $AnimationPlayer.current_animation == "swing":
				is_attacking = true
	if parentname == "PlayerTwo":
		if Input.is_action_just_pressed("p2_attack") and can_attack == true:
			$AnimationPlayer.play("swing")
			can_attack = false
			attacktimer.start()
			swingtimer.start()
			if $AnimationPlayer.current_animation == "swing":
				is_attacking = true



func _on_Sword_body_entered(body):
	var parentname = get_parent().name
	if body.name == "PlayerTwo":
		is_in_body = true
		if is_attacking == true and is_in_body == true:
			if parentname == "PlayerOne":
				get_node("/root/TestLevel/CanvasLayer/FightUI/Player2Health").value -= 20
			if parentname == "PlayerTwo":
				get_node("/root/TestLevel/CanvasLayer/FightUI/Player1Health").value -= 20
			is_in_body = false

func _on_Timer_timeout():
	is_attacking = false
	$AnimationPlayer.stop()


#func _on_Sword_body_exited(body):
	#if body.name == "PlayerTwo":
		#is_in_body = false


func _on_Timer2_timeout():
	can_attack = true
