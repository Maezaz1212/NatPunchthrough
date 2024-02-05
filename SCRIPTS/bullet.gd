extends Node2D

var speed = 1

func  _physics_process(delta):
	move_local_x(speed)
