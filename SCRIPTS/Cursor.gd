extends Node2D

var velocity : Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	if parent.controller:
		parent.MoveAxisChangedSignal.connect(onMoveAxisChange)
	else:
		parent.MousePositionChangeSignal.connect(onMousePositionChange)
		set_process(false)

	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = global_position + (velocity * 30)
	pass


func onMoveAxisChange(new_move_axis : Vector2):
	velocity = new_move_axis

func onMousePositionChange(new_mouse_pos : Vector2):
	global_position = new_mouse_pos
