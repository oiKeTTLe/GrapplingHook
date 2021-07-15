extends Control


func _process(delta):
	if $Player1Health.value == 0:
		get_tree().change_scene("res://Game Over.tscn")
	if $Player2Health.value == 0:
		get_tree().change_scene("res://Game Over.tscn")
