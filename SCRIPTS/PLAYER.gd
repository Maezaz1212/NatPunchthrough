extends CharacterBody2D

var sync_id = ""
var Speed = 300.0 : set = set_speed
const JUMP_VELOCITY = -400.0

var frame_before_pos = Vector2.ZERO
var frame_before_move_dir = 0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_local_player = false


@export var jump_command  = false
@export var move_dir = Vector2.ZERO
var parent;

func _ready():
	parent = get_parent()
	print(parent)
	parent.MoveAxisChangedSignal.connect(onMoveAxisChange)
	parent.LookAxisChangedSignal.connect(onLookAxisChange)
	parent.MousePositionChangeSignal.connect(onMousePositionChange)

func _physics_process(delta):
	# Handle jump.
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if jump_command and is_on_floor():
		velocity.y = JUMP_VELOCITY
	jump_command = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if move_dir:
		velocity.x = move_dir.x * Speed
		if move_dir.x < 0:
			$AnimatedSprite2D.flip_h = true
		elif move_dir.x > 0:
			$AnimatedSprite2D.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, Speed)
	
	move_and_slide()
	


func set_speed(new_speed : int):
	Speed = new_speed
		
func onMoveAxisChange(new_move_axis):
	move_dir = new_move_axis;

func onLookAxisChange(new_look_axis):
	pass

func onMousePositionChange(new_mouse_pos):
	pass
