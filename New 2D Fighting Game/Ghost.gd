extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$alpha_tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0.75), Color(1, 1, 1, 0), .4, Tween.TRANS_SINE, Tween.EASE_OUT)
	$alpha_tween.start()
func _on_alpha_tween_tween_completed(object, key):
	queue_free()
