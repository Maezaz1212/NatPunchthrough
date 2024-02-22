extends AnimatableBody2D

@export var velocity := Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position = global_position.lerp(global_position + velocity,delta * 10)
	pass


func _on_time_till_turn_timer_timeout():
	velocity = Vector2(-velocity.x,-velocity.y)

