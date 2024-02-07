extends Sprite2D

var parent;
var velocity = Vector2(0,0);
# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	parent.MoveAxisChangedSignal.connect(onMoveAxisChange)
	parent.LookAxisChangedSignal.connect(onLookAxisChange)
	parent.MousePositionChangeSignal.connect(onMousePositionChange)

func onMoveAxisChange(new_move_axis):
	print("MOVED")

func onLookAxisChange(new_look_axis):
	velocity = new_look_axis;

func onMousePositionChange(new_mouse_pos):
	global_position = new_mouse_pos
	
	
	
