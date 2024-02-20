extends Area2D

var velocity = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = global_position.lerp(global_position + velocity,delta * 10)
	pass


func _on_body_entered(body):
	if !Relayconnect.IS_HOST:
		return
	
	if body.get_class() == "CharacterBody2D" and get_parent().race_started:
		body.is_dead = true
